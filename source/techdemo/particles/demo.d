module techdemo.particles.demo;

import std.exception : enforce;
import std.datetime : seconds;
import std.string : format;

import zyeware.common;
import zyeware.rendering;

class ParticlesDemo : GameState
{
protected:
    OrthographicCamera mUICamera;
    Font mFont;
    Particles2D mParticles;
    ParticleRegistrationID mStarParticlesId;

public:
    this(GameStateApplication application)
    {
        super(application);
    }

    override void tick(in FrameTime frameTime)
    {
        mParticles.create(mStarParticlesId, ZyeWare.application.window.cursorPosition, 1);
        mParticles.tick(frameTime);

        if (InputManager.isActionJustPressed("ui_cancel"))
            application.popState();
    }

    override void draw(in FrameTime nextFrameTime)
    {
        RenderAPI.clear();

        Renderer2D.begin(mUICamera.projectionMatrix, mat4.identity);
        Renderer2D.drawText(format!"Active particles: %d"(mParticles.count), mFont, Vector2f(4), Color.white);
        mParticles.draw(nextFrameTime);
        Renderer2D.end();
    }
    
    override void onAttach(bool firstTime)
    {
        if (firstTime)
        {
            mUICamera = new OrthographicCamera(0, 640, 480, 0);
            mFont = AssetManager.load!Font("core://fonts/internal.fnt");
            mParticles = new Particles2D();

            Gradient gradient;
            gradient.addPoint(0, Color.red);
            gradient.addPoint(0.5, Color.blue);
            gradient.addPoint(1, Color.yellow);

            ParticleProperties2D starType;

            starType.texture = AssetManager.load!Texture2D("res://menu/menuStar.png");
            starType.gravity = Vector2f(0, 15);
            starType.speed.min = 30f;
            starType.speed.max = 300f;
            starType.lifeTime.min = seconds(1);
            starType.lifeTime.max = seconds(3);
            //starType.color = gradient;

            mStarParticlesId = mParticles.registerType(starType, 1024);
        }
    }
}