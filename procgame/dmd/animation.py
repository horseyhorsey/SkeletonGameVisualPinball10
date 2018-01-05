import os
import struct
import yaml
import sqlite3
import bz2
try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO
import time
from PIL import Image
# simple work-around to support PIL or PILLOW
if(not hasattr(Image.Image,"tobytes")):
    Image.Image.tobytes = Image.Image.tostring
import dmd
from dmd import Frame
from sdl2_displaymanager import sdl2_DisplayManager
from procgame import config
import logging
import re
import colorsys
import zipfile

# import pygame
# from pygame import movie
try:
    import cv2
    import cv2.cv as cv
    OpenCV_avail = True
except ImportError:
    OpenCV_avail = False

# Global reference; use AnimationCacheManager.shared_manager() to create and reference.
shared_cache_manager = None

warned_cache_disabled = False

class AnimationCacheManager(object):
    def __init__(self, path):
        self.path = os.path.expanduser(path)
        if not os.path.exists(self.path):
            os.makedirs(self.path)
        self.load()
        # TODO: Check cache for deleted files?

    def __del__(self):
        self.conn.close()
        del self.conn

    def shared_manager():
        """Returns a reference to the global, shared manager, if configured by the
        ``dmd_cache_path`` in :mod:`procgame.config`."""
        global shared_cache_manager
        if not shared_cache_manager:
            path = config.value_for_key_path('dmd_cache_path')
            if path:
                shared_cache_manager = AnimationCacheManager(path)
            else:
                shared_cache_manager = None
        return shared_cache_manager
    shared_manager = staticmethod(shared_manager)

    def database_path(self):
        return os.path.join(self.path, 'cache.db')

    def load(self):
        DATABASE_VERSION = 1
        CREATE_VERSION_TABLE = '''create table if not exists version (version integer)'''
        CREATE_ENTRIES_TABLE = '''create table if not exists entries (path text, created integer, accessed integer, compression text, data blob)'''
        self.conn = sqlite3.connect(self.database_path())
        self.conn.execute(CREATE_VERSION_TABLE)

        # Now check for any existing version information:
        c = self.conn.cursor()
        c.execute('''select version from version limit 1''')
        result = c.fetchone()
        if not result:
            c.execute('''insert into version values (?)''', (DATABASE_VERSION,))
        else:
            (version,) = result
            if version == DATABASE_VERSION:
                pass # we are up to date
            else:
                import pdb; pdb.set_trace()
                logging.getLogger('game.dmdcache').warning('DMD cache database version (%d) is not current (%d).  Cache will be rebuilt.', version, DATABASE_VERSION)
                del self.conn
                os.remove(self.database_path())
                return self.load()

        self.conn.execute(CREATE_ENTRIES_TABLE)
        self.conn.commit()

    def invalidate_path(self, path):
        self.conn.execute('''delete from entries where path=?''', (path,))

    def get_at_path(self, path, compare_created_time = None):
        """Attempt to retrieve data from the cache for *path*; returns ``None`` if not present.
        If the created time on the cache entry is before *compare_created_time*, ``None`` will be returned."""
        self.conn.execute('''update entries set accessed=?''', (int(time.time()),))
        c = self.conn.cursor()
        c.execute('''select data, created from entries where path=?''', (path,))
        result = c.fetchone()
        if not result:
            return None
        (data, created) = result
        if compare_created_time and compare_created_time > created:
            return None
        else:
            return bz2.decompress(data)

    def set_at_path(self, path, data):
        """Save *data* for the given *path* in the cache."""
        self.invalidate_path(path)
        data = bz2.compress(data)
        created = accessed = int(time.time())
        self.conn.execute('''insert into entries values (?, ?, ?, ?, ?)''', (path, created, accessed, 'bzip2', sqlite3.Binary(data)))
        self.conn.commit()


class Animation(object):
    """An ordered collection of :class:`~procgame.dmd.Frame` objects."""

    width = None
    """Width of each of the animation frames in dots."""
    height = None
    """Height of each of the animation frames in dots."""
    frames = []
    """Ordered collection of :class:`~procgame.dmd.Frame` objects."""

    def __init__(self):
        """Initializes the animation."""
        super(Animation, self).__init__()
        self.frames = []

    def load(self, filename, allow_cache=True, composite_op=None, use_streaming_mode=False, png_stream_cache=False):
        """Loads *filename* from disk.  The native animation format is the
        :ref:`dmd-format`, which can be created using :ref:`tool-dmdconvert`, or
        `DMDAnimator <https://github.com/preble/DMDAnimator>`_.

        This method also supports loading common image formats such as PNG, GIF,
        and so forth using
        `Python Imaging Library <http://www.pythonware.com/products/pil/>`_.
        Note that loading such images can be time-consuming.  As such, a caching
        facility is provided.  To enable animation caching, provide a path using the
        ``dmd_cache_path`` key in :ref:`config-yaml`.  Note that only non-native
        images are cached (.dmd files are not cached).

        *filename* can be a string or a list.  If it is a list, the images pointed
        to will be appended to the animation.
        """

        # Allow the parameter to be a single filename, or a list of filenames.
        paths = list()
        if type(filename) != list:
            if re.search("%[0-9]*d", filename):
                frame_index = 0
                while True:
                    tmp_filename = filename % (frame_index)
                    if os.path.exists(tmp_filename):
                        paths += [tmp_filename]
                        frame_index += 1
                    else:
                        break;
            else:
                paths += [filename]

        paths = map(os.path.abspath, paths)

        # The path that is used as the key in the database
        if(len(paths)==0):
            raise ValueError, "Load FAILED: could not locate a file matching [%s]" % filename
        key_path = paths[0]

        self.frames = []

        animation_cache = None
        if allow_cache:
            animation_cache = AnimationCacheManager.shared_manager()

        logger = logging.getLogger('game.dmdcache')
        t0 = time.time()
        data = None

        if animation_cache:
            # Check the cache for this data:
            if os.path.exists(key_path):
                data = animation_cache.get_at_path(key_path, os.path.getmtime(key_path))

        # If there was data in the cache:
        if data:
            # If it was in the cache, we know that it is in the dmd format:
            self.populate_from_dmd_file(StringIO(data))
            # print "Loaded", path, "from cache",
            logger.debug('Loaded "%s" from cache in %0.3fs', key_path, time.time()-t0)
        else:
            # Not in the cache, so we must load from disk:
            logger.info('Loading %s...', key_path) # Log for images...

            if(use_streaming_mode):
                # do special stuff for png streaming
                # back up the composite op
                self.composite_op = composite_op
                # 1. save the file name
                self.filenames = paths

                # 2. use an on demand frame list instead of a regular list.
                self.frames = OnDemandFrameList(0,self.load_single_frame, png_stream_cache)
                self.frames.set_count(len(self.filenames))

                return self
                # otherwise, proceed as usual

            # Iterate over the provided paths:
            for path in paths:
                if (os.path.isfile(path.rstrip('.zip'))):
                    #print("Using unzipped DMD for '" + path + "'")
                    path = path.rstrip('.zip')
                # Opening from disk.  It may be a DMD, or it may be another format.
                # We keep track of the DMD data representation so we can save it to
                # the cache.
                ext = path[-4:].lower()
                if ext =='.dmd':
                    # Note: Right now we don't cache .dmd files.
                    with open(path, 'rb') as f:
                        self.populate_from_dmd_file(f, composite_op = composite_op)
                elif ext =='.zip':
                    z = zipfile.ZipFile(path, "r")
                    data = z.read(z.namelist()[0])    #Read in the first image data
                    self.populate_from_dmd_file(StringIO(data), composite_op = composite_op)
                elif ext =='.mp4' or ext == '.avi':
                    self.populate_from_mp4_file(path)
                else:
                    # logger.info('Loading %s...', path) # Log for images...
                    global warned_cache_disabled
                    if not animation_cache and not warned_cache_disabled and allow_cache:
                        logger.warning('Loading image file with caching disabled; set dmd_cache_path in config to enable.')
                        warned_cache_disabled = True

                    # It is some other file format.  We will use PIL to open it
                    # and then process it into a .dmd format.
                    with open(path, 'rb') as f:
                        self.populate_from_image_file_sdl2(path, f, composite_op = composite_op)

            # Now use our normal save routine to get the DMD format data:
            # stringio = StringIO.StringIO()
            # self.save_to_dmd_file(stringio)
            # dmd_data = stringio.getvalue()

            # Finally store the data in the cache:
            if animation_cache:
                #print "Storing in the cache: ", key_path
                animation_cache.set_at_path(key_path, dmd_data)

            # print('Loaded "%s" from disk in %0.3fs', key_path, time.time()-t0)

        return self

    def save(self, filename):
        """Saves the animation as a .dmd file at the given location, `filename`."""
        if self.width == None or self.height == None:
            raise ValueError, "width and height must be set on Animation before it can be saved."
        with open(filename, 'wb') as f:
            self.save_to_dmd_file(f)

    def save_old(self, filename):
        """Saves the animation as a 'traditional' (8bpp) .dmd file at the given location, `filename`."""
        if self.width == None or self.height == None:
            raise ValueError, "width and height must be set on Animation before it can be saved."
        with open(filename, 'wb') as f:
            self.save_to_old_dmd_file(f)

    def convertImage(src):

        image = src.convert("RGBA")
        (w,h) = image.size

        frame = Frame(w, h)
        mode = image.mode
        size = image.size
        data = image.tostring()

        #assert mode in 'RGB', 'RGBA'
        # surface = pygame.image.fromstring(data, size, mode)

        #raise ValueError, "convertImage doesn't work..."
        frame.pySurface = HD_make_texture_from_bits(data, w, h)
        # print("ConvertImage made texture for this frame -- contents: " + str(new_frame.pySurface))


        # frame.set_surface(surface)

        return frame

    convertImage = staticmethod(convertImage)

    def convertImageToOldDMD(src):
        pal_image= Image.new("P", (1,1))
        tuplePal = VgaDMD.get_palette()
        flatPal = [element for tupl in tuplePal for element in tupl]
        pal_image.putpalette(flatPal)
        src_rgb = src.convert("RGB").quantize(palette=pal_image)
        src_p = src_rgb.convert("P")

        (w,h) = src.size
        frame = Frame(w, h)
        for x in range(w):
            for y in range(h):
                color = src_p.getpixel((x,y))
                frame.set_dot(x=x, y=y, value=color)
        return frame
    convertImageToOldDMD = staticmethod(convertImageToOldDMD)

    def populate_from_image_file_sdl2(self, path, f, composite_op = None):
        # print("loading %s" % f)
        tx = sdl2_DisplayManager.inst().load_texture(path, composite_op)
        (self.width,self.height) = tx._size
        frame = Frame(self.width,self.height,tx)
        self.frames.append(frame)

    def populate_from_image_file(self, path, f, composite_op = None):
        if not Image:
            raise RuntimeError, 'Cannot open non-native image types without Python Imaging Library: %s' % (path)

        src = Image.open(f)

        (w, h) = src.size
        # print ("conversion of image, sized " + str(w) + "," + str(h))

        if len(self.frames) > 0 and (w != self.width or h != self.height):
            raise ValueError, "Image sizes must be uniform!  Anim is %dx%d, image is %dx%d" % (w, h, self.width, self.height)

        (self.width, self.height) = (w, h)

        # I'm punting on animated gifs, because they're too slow.  If you coalesce them
        # via image magic then they are fast again.
        if path.endswith('.gif'):
            import animgif
            self.frames += animgif.gif_frames(src, composite_op = composite_op)
        else:
            (w,h) = src.size

            if src.mode == "P":
                src.convert("RGB")
                src.mode = "RGB"
            surf = sdl2_DisplayManager.inst().make_texture_from_imagebits(bits=src.tobytes(), width=w, height=h, mode=src.mode, composite_op = composite_op)

            frame = Frame(w,h,surf)

            self.frames.append(frame)


    def populate_from_dmd_file(self, f, composite_op = None):
        f.seek(0, os.SEEK_END) # Go to the end of the file to get its length
        file_length = f.tell()

        f.seek(0) # Skip back to the 4 byte DMD header.
        dmd_version = struct.unpack("I", f.read(4))[0]
        dmd_style = 0 # old
        if(dmd_version == 0x00646D64):
            # print("old dmd style")
            pass
        elif(dmd_version == 0x00DEFACE):
            # print("full color dmd style")
            dmd_style = 1

        frame_count = struct.unpack("I", f.read(4))[0]
        self.width = struct.unpack("I", f.read(4))[0]
        self.height = struct.unpack("I", f.read(4))[0]
        if(dmd_style==0):
            if file_length != 16 + self.width * self.height * frame_count:
                logging.getLogger('game.dmdcache').warning(f)
                logging.getLogger('game.dmdcache').warning("expected size = {%d} got {%d}", (16 + self.width * self.height * frame_count), (file_length))
                raise ValueError, "File size inconsistent with original DMD format header information.  Old or incompatible file format?"
        elif(dmd_style==1):
            if file_length != 16 + self.width * self.height * frame_count * 3:
                logging.getLogger('game.dmdcache').warning(f)
                raise ValueError, "File size inconsistent with true-color DMD format header information. Old or incompatible file format?"

        for frame_index in range(frame_count):
            new_frame = Frame(self.width, self.height)
            if(dmd_style==0):
                str_frame = f.read(self.width * self.height)
                new_frame.build_surface_from_8bit_dmd_string(str_frame, composite_op)
            elif(dmd_style==1):
                str_frame = f.read(self.width * self.height * 3)
                new_frame.pySurface = sdl2_DisplayManager.inst().make_texture_from_imagebits(bits=str_frame, width=self.width, height=self.height, composite_op=composite_op)
                if(frame_index==1):
                    new_frame.font_dots = str_frame[0:97]
            self.frames.append(new_frame)

    def save_to_old_dmd_file(self, f):
        header = struct.pack("IIII", 0x00646D64, len(self.frames), self.width, self.height)
        if len(header) != 16:
            raise ValueError, "Packed size not 16 bytes as expected: %d" % (len(header))
        f.write(header)
        for frame in self.frames:
            str1 = ''.join(str(e) for e in frame.font_dots)
            print("font dots=[" + str1 + "]")
            f.write(str1)

    def save_to_dmd_file(self, f):
        header = struct.pack("IIII", 0x00DEFACE, len(self.frames), self.width, self.height)
        if len(header) != 16:
            raise ValueError, "Packed size not 16 bytes as expected: %d" % (len(header))
        f.write(header)
        for frame in self.frames:
            f.write(frame.get_surface_string())


    def populate_from_mp4_file(self,file):
        if(cv2 is None):
            raise ValueError, "MP4 is unavailable as OpenCV is not installed"
        vc = cv2.VideoCapture(file)
        self.width = int(vc.get(cv.CV_CAP_PROP_FRAME_WIDTH))
        self.height = int(vc.get(cv.CV_CAP_PROP_FRAME_HEIGHT))
        frame_count  = int(vc.get(cv.CV_CAP_PROP_FRAME_COUNT))
        #vc.set(cv.CV_CAP_PROP_CONVERT_RGB, True)

        #print "width:" + str(self.width) + "   Height: " + str(self.height) + "frame count: " + str(frame_count)

        for i in range(frame_count):
            rval, video_frame = vc.read()
            if rval is not None:
                video_frame = cv2.cvtColor(video_frame,cv2.cv.CV_BGR2RGB)
                the_frame = cv.fromarray(video_frame)
                # surface = pygame.image.frombuffer(the_frame.tostring(), (self.movie.width, self.movie.height), 'RGB')
                surf = sdl2_DisplayManager.inst().make_texture_from_imagebits(bits=the_frame.tostring(), width=self.width, height=self.height, mode='RGB', composite_op = None)
                new_frame = Frame(self.width, self.height, from_surface=surf)
                self.frames.append(new_frame)

        vc.release()

    ##### NEW: SUPPORT FOR STREAMING PNG -- TODO, RE-WRITE MOVIE TO USE THIS!

    def load_single_frame(self, idx):
        ## ONLY USE THIS FROM STREAMING LOAD!!
        path = self.filenames[idx]
        print("loading %s" % path)

        tx = sdl2_DisplayManager.inst().load_texture(path, self.composite_op)
        (self.width,self.height) = tx._size
        frame = Frame(self.width,self.height,tx)
        return frame


class OnDemandFrameList(object):
    """ a list that knows when items are absent, but also knows how many it should have... """
    def __init__(self, count, function_on_miss, enable_caching=False):
        self.enable_caching = enable_caching
        self.__miss_fn = function_on_miss
        self.set_count(count)

    def set_count(self, ct):
        self.__size = ct
        if(self.enable_caching):
            self.__items = [None for _ in range(ct)]

    def __getitem__(self, index):
        if(self.enable_caching):
            if(self.__items[index] is None):
                self.__items[index] = self.__miss_fn(index)
            return self.__items[index]
        else:
            return self.__miss_fn(index)

    def __len__(self):
        return self.__size
