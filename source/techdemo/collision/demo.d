module techdemo.collision.demo;

import std.random : uniform;

import zyeware.common;
import zyeware.core.gamestate;
import zyeware.ecs;
import zyeware.rendering;

class CollisionDemo : GameState
{
protected:
    OrthographicCamera mCamera;
    Transform2DComponent mFirstTransform;
    Transform2DComponent mSecondTransform;
    Shape2D mFirstShape;
    Shape2D mSecondShape;
    Texture2D mCircleTexture;

public:
    this(GameStateApplication application)
    {
        super(application);

        mCamera = new OrthographicCamera(0, 640, 480, 0);

        mFirstTransform = Transform2DComponent(Vector2f(100, 240));
        mSecondTransform = Transform2DComponent(Vector2f(400, 240));

        mCircleTexture = AssetManager.load!Texture2D("res://sprites/circle.png");

        mSecondShape = new RectangleShape2D(Vector2f(50));
        mFirstShape = new CircleShape2D(50);
        //mFirstShape = mSecondShape;

        Logger.client.log(LogLevel.debug_, "%(%s, %)", (cast(RectangleShape2D) mSecondShape).vertices);
    }

    override void tick(in FrameTime frameTime)
    {
        immutable float delta = frameTime.deltaTime.toFloatSeconds;

        Vector2f position = mSecondTransform.position;
        float rotation = mSecondTransform.rotation;

        position.x += (InputManager.getActionStrength("ui_right") - InputManager.getActionStrength("ui_left")) * 100f * delta;
        position.y += (InputManager.getActionStrength("ui_down") - InputManager.getActionStrength("ui_up")) * 100f * delta;

        mSecondTransform.position = position;
        mSecondTransform.rotation = rotation;

        if (InputManager.isActionPressed("ui_accept"))
            rotation += 100.radians * delta;
        else if (InputManager.isActionJustPressed("ui_cancel"))
            application.popState();
    }

    override void draw(in FrameTime nextFrameTime)
    {
        RenderAPI.clear();

        auto r = Rect2f(-50, -50, 50, 50);
        Collision2D collision = mFirstShape.checkCollision(mFirstTransform.globalMatrix, mSecondShape, mSecondTransform.globalMatrix);
        Color c = collision.isColliding ? Color(0, 1, 0, 1) : Color(1, 0, 0, 1);

        Renderer2D.begin(mCamera.projectionMatrix, mat4.identity);

        Renderer2D.drawRect(r, mFirstTransform.globalMatrix, c, mCircleTexture);
        Renderer2D.drawRect(r, mSecondTransform.globalMatrix, c);

        Renderer2D.end();
    }
}
