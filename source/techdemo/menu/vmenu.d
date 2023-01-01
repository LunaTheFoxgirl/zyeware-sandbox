module techdemo.menu.vmenu;

import std.typecons : Tuple;

import zyeware.common;
import zyeware.rendering;
import zyeware.audio;

class VerticalMenu
{
protected:
    const Font mFont;
    Entry[] mEntries;
    int mCursor;

    Sound mCursorUp, mCursorDown, mAccept;
    AudioSampleSource mSource;

public:
    struct Entry
    {
        alias Callback = void delegate();

        string text;
        bool disabled;
        Callback onActivated;
        Callback onSelected;
    }

    this(Entry[] entries, in Font font)
    {
        mEntries = entries;
        mFont = font;

        mCursorUp = AssetManager.load!Sound("res://menu/up.wav");
        mCursorDown = AssetManager.load!Sound("res://menu/down.wav");
        mAccept = AssetManager.load!Sound("res://menu/accept.wav");

        mSource = new AudioSampleSource(null);
    }

    void handleActionEvent(InputEventAction action)
    {
        if (action.isPressed) switch (action.action)
        {
        case "ui_up":
            do
            {
                mCursor -= 1;
                if (mCursor < 0)
                    mCursor += mEntries.length;
            }
            while (mEntries[mCursor].disabled);

            if (mEntries[mCursor].onSelected)
                mEntries[mCursor].onSelected();

            mSource.buffer = mCursorUp;
            mSource.play();
            break;

        case "ui_down":
            do
            {
                mCursor += 1;
                if (mCursor >= mEntries.length)
                    mCursor -= mEntries.length;
            }
            while (mEntries[mCursor].disabled);

            if (mEntries[mCursor].onSelected)
                mEntries[mCursor].onSelected();

            mSource.buffer = mCursorDown;
            mSource.play();
            break;

        case "ui_accept":
            if (mEntries[mCursor].onActivated)
                mEntries[mCursor].onActivated();

            mSource.buffer = mAccept;
            mSource.play();
            break;

        default:
        }
    }

    void draw(Vector2f topCenterPos)
    {
        for (size_t i; i < mEntries.length; ++i)
        {
            Color color;
            if (mEntries[i].disabled)
                color = Color.gray;
            else
                color = mCursor == i ? Color.yellow : Color.white;

            Renderer2D.drawText(mEntries[i].text, mFont, topCenterPos + Vector2f(0, i * mFont.bmFont.common.lineHeight + 4), color, Font.Alignment.center);
        }
    }
}
