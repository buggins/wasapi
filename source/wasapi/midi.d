module wasapi.midi;

version(Windows):

import core.sys.windows.mmsystem;
import wasapi.comutils;

class MidiOutDeviceDesc {
    uint index;
    string name;
    uint technology;
    ushort channelMask;

    MidiOutDevice open() {
        MidiOutDevice res = new MidiOutDevice(this);
        if (!res.open())
            return null;
        return res;
    }
}

class MidiOutDevice {
    private HMIDIOUT handle;
    private MIDIHDR hdr;
    protected MidiOutDeviceDesc desc;
    protected bool closed = true;
    protected bool hdrPrepared;
    protected this(MidiOutDeviceDesc desc) {
        this.desc = desc;
    }
nothrow @nogc:
    void sendEvent(ubyte b1) {
        midiOutShortMsg(handle, b1);
    }
    void sendEvent(ubyte b1, ubyte b2) {
        midiOutShortMsg(handle, b1 | (cast(uint)b2 << 8));
    }
    void sendEvent(ubyte b1, ubyte b2, ubyte b3) {
        midiOutShortMsg(handle, b1 | (cast(uint)b2 << 8) | (cast(uint)b3 << 16));
    }
    void sendEvent(ubyte b1, ubyte b2, ubyte b3, ubyte b4) {
        midiOutShortMsg(handle, b1 | (cast(uint)b2 << 8) | (cast(uint)b3 << 16) | (cast(uint)b4 << 24));
    }
    protected bool open() {
        if (midiOutOpen(&handle, desc.index, 0, 0, CALLBACK_NULL) != MMSYSERR_NOERROR)
            return false;
        closed = false;
        if (midiOutPrepareHeader(handle, &hdr, MIDIHDR.sizeof) != MMSYSERR_NOERROR) {
            close();
            return false;
        }
        hdrPrepared = true;
        return true;
    }
    void close() {
        if (closed)
            return;
        if (handle) {
            if (hdrPrepared) {
                midiOutUnprepareHeader(handle, &hdr, MIDIHDR.sizeof);
                hdrPrepared = false;
            }
            midiOutReset(handle);
            midiOutClose(handle);
            handle = null;
        }
        closed = true;
    }
    ~this() {
        close();
    }
}

immutable uint DEFAULT_MIDI_DEVICE = uint.max;

class MidiProvider {
    @property uint inputDevCount() {
        return midiInGetNumDevs();
    }
    @property uint outDevCount() {
        return midiOutGetNumDevs();
    }

    MidiOutDeviceDesc getOutputDevice(uint index = DEFAULT_MIDI_DEVICE) {
        import std.utf;
        if (index == DEFAULT_MIDI_DEVICE)
            index = MIDI_MAPPER;
        MIDIOUTCAPS caps;
        if (midiOutGetDevCaps(index, &caps, MIDIOUTCAPS.sizeof) != MMSYSERR_NOERROR)
            return null;
        MidiOutDeviceDesc res = new MidiOutDeviceDesc();
        res.index = index;
        res.name = fromWstringz(caps.szPname.ptr).toUTF8;
        res.technology = caps.wTechnology;
        res.channelMask = caps.wChannelMask;
        return res;
    }
}

