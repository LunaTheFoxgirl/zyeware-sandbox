module techdemo.gamepad.demo;

import std.exception : enforce;
import std.string : format;

import zyeware.common;
import zyeware.rendering;

class GamepadDemo : GameState
{
protected:
    OrthographicCamera mUICamera;
    Font mFont;
    size_t mCurrentGamepadIndex;

public:
    this(GameStateApplication application)
    {
        super(application);
    }

    override void tick(in FrameTime frameTime)
    {
        if (InputManager.isActionPressed("ui_accept"))
        {
            if (InputManager.isActionJustPressed("ui_left"))
            {
                if (mCurrentGamepadIndex == 0)
                    mCurrentGamepadIndex = 31;
                else
                    --mCurrentGamepadIndex;
            }
            else if (InputManager.isActionJustPressed("ui_right"))
            {
                mCurrentGamepadIndex = (mCurrentGamepadIndex + 1) % 32;
            }
            else if (InputManager.isActionJustPressed("ui_cancel"))
                application.popState();
        }
    }

    override void draw(in FrameTime nextFrameTime)
    {
        RenderAPI.clear();

        Renderer2D.begin(mUICamera.projectionMatrix, mat4.identity);

        Renderer2D.drawText(tr("gamepadDemo.header").format(mCurrentGamepadIndex), mFont, Vector2f(4));

        for (GamepadButton b = GamepadButton.min; b <= GamepadButton.max; ++b)
            Renderer2D.drawText(format!"%s: %s"(b, application.window.isGamepadButtonPressed(mCurrentGamepadIndex, b)),
                mFont, Vector2f(40, 140 + b * 16));

        for (GamepadAxis a = GamepadAxis.min; a <= GamepadAxis.max; ++a)
            Renderer2D.drawText(format!"%s: %.3f"(a, application.window.getGamepadAxisValue(mCurrentGamepadIndex, a)),
                mFont, Vector2f(300, 140 + a * 16));

        Renderer2D.end();
    }
    
    override void onAttach(bool firstTime)
    {
        if (firstTime)
        {
            mUICamera = new OrthographicCamera(0, 640, 480, 0);
            mFont = AssetManager.load!Font("core://fonts/internal.fnt");
        }
    }
}