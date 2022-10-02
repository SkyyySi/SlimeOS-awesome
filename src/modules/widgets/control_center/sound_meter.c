/*
MIT License

Copyright (c) [2016] [Hsin-Wu "John" Liu]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

// Allow to use this as a Lua module
#include <luajit-2.1/lua.h>
#include <luajit-2.1/lualib.h>
#include <luajit-2.1/lauxlib.h>

#include <alsa/asoundlib.h>
#include <math.h>
#include <stdbool.h>

/// <audio-read>
static char* device = "default";
static short* buffer;
static int buffer_size;

static double rms(short* buffer) {
	long square_sum = 0.0;
	for (int i = 0; i < buffer_size; i++) {
		square_sum += (buffer[i]*buffer[i]);
	}

	double result = sqrt(square_sum / buffer_size);
	return result;
}

static int get_volume() {
	snd_pcm_t* handle_capture;
	snd_pcm_sframes_t frames;

	int err;

	err = snd_pcm_open(&handle_capture, device, SND_PCM_STREAM_CAPTURE, 0);
	if (err < 0) {
		printf("Capture open error: %s\n", snd_strerror(err));
		exit(EXIT_FAILURE);
	}

	err = snd_pcm_set_params(handle_capture,
		SND_PCM_FORMAT_S16_LE,
		SND_PCM_ACCESS_RW_INTERLEAVED,
		1,
		48000,
		1,
		500000
	);

	if (err < 0) {
		printf("Capture open error: %s\n", snd_strerror(err));
		exit(EXIT_FAILURE);
	}

	double k = 0.45255;
	double Pvalue = 0;

	frames = snd_pcm_readi(handle_capture, buffer, buffer_size);

	if (frames < 0) {
		// Try to recover
		frames = snd_pcm_recover(handle_capture, frames, 0);
		if (frames < 0) {
			printf("snd_pcm_readi failed: %s\n", snd_strerror(err));
		}
	}

	if (frames > 0 && frames < (long)buffer_size) {
		printf("Short read (expected %li, read %li)\n", (long)buffer_size, frames);
	}

	// Successfully read, calculate dB
	Pvalue = rms(buffer) * k;

	int dB = 0;
	if (Pvalue > 0) {
		dB = (int)20 * log10(Pvalue);
	}

	if (dB < 0) {
		dB = 0;
	}

	snd_pcm_close(handle_capture);

	return dB;
}

static int run(lua_State* L) {
	int buff_size = (int)luaL_checknumber(L, 1);

	buffer = malloc(buff_size * 2); // a short takes 2 bytes
	buffer_size = buff_size;

	int retval = get_volume();

	free(buffer);

	// push the current volume onto the Lua return stack
	lua_pushnumber(L, retval);

	return 1;
}
/// </audio-read>

//library to be registered
static const struct luaL_Reg sound_meter[] = {
	{"run", run},
	{NULL, NULL}  // sentinel
};

//name of this function is not flexible
int luaopen_sound_meter(lua_State* L) {
	luaL_newlib(L, sound_meter);
	return 1;
}
