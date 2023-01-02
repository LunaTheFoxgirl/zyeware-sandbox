module techdemo.menu.menu;

import std.algorithm : min, max;
import std.math : sqrt, sin, cos, tan, PI;
import std.string : format;
import std.random : uniform;
import std.datetime : Duration, dur;

import zyeware.common;
import zyeware.rendering;
import zyeware.audio;

import techdemo.menu.vmenu;
import techdemo.menu.background;
import techdemo.creeps.gamestates.menustate;
import techdemo.mesh.demo;
import techdemo.terrain.demo;
import techdemo.collision.demo;
import techdemo.gamepad.demo;
import techdemo.particles.demo;

private static immutable Vector2f screenCenter = Vector2f(320, 240);

class DemoMenu : GameState
{
protected:
    static size_t sCurrentLocale = 0;

    bool mCrashOnNextFrame;
    OrthographicCamera mUICamera;
    VerticalMenu mMainMenu;
    Font mFont;
    MenuBackground mBackground;
    AudioSampleSource mBackSoundSource;
    Texture2D mLogoTexture;

    void processStarPattern(Duration frameTime)
    {
        static size_t currentPattern = 0;
        static Duration currentPatternDuration;

        while (!frameTime.isNegative)
        {
            immutable Duration stepDur = dur!"msecs"(10);
            currentPatternDuration += stepDur;
            immutable float patternSecs = currentPatternDuration.total!"msecs" / 1000f;

            final switch (currentPattern)
            {
            case 0: // Morphing circle
                static int timer;

                immutable float distance = 100f;
                immutable float morphValueX = 0.7 + sin(patternSecs) * 0.3;
                immutable float morphValueY = 0.7 + cos(patternSecs) * 0.3;

                timer -= stepDur.total!"msecs";
                
                if (timer <= 0)
                {
                    for (float angle = 0f; angle < PI*2; angle += 0.08)
                        mBackground.spawn(screenCenter.x + cos(angle) * distance * morphValueX,
                            screenCenter.y + sin(angle) * distance * morphValueY);
                    
                    timer = 150;
                }
                break;

            case 1: // Weird
                static immutable float[][] data = [
                    [ 4f, 150f, 7f, 50f ],
                    [ 6f, 50f, 3f, 150f ],
                    [ 9f, 90f, 6f, 110f ],
                    [ 7f, 20f, 1f, 200f ],
                    [ 1f, 40f, 4f, 130f ],
                    [ 2f, 120f, 3f, 170f ],
                    [ 3f, 110f, 2f, 90f ],
                    [ 4f, 200f, 1f, 180f ],
                ];

                for (size_t i; i < data.length; ++i)
                    mBackground.spawn(
                        screenCenter.x + cos(patternSecs + sin(patternSecs) * data[i][0]) * data[i][1],
                        screenCenter.y + sin(patternSecs + cos(patternSecs) * data[i][2]) * data[i][3]
                    );
                break;

            case 2: // Starfield
                float rand()
                {
                    return uniform(-0.5f, 0.5f) * uniform(0f, 1f);
                }

                for (size_t i; i < 3; ++i)
                    mBackground.spawn(screenCenter.x + rand() * 640f, screenCenter.y + rand() * 480f);
                break;

            case 3:
                immutable float angle = patternSecs * 2f + sin(patternSecs * 5f);
                immutable float distance = 100f + cos(patternSecs) * 25f;
                immutable Vector2f spawnPos = screenCenter + Vector2f(cos(patternSecs * 2f) * 100f, sin(patternSecs) * 50f);

                for (int i; i < 4; ++i)
                    mBackground.spawn(
                        spawnPos.x + cos(angle + (PI/2) * i) * distance,
                        spawnPos.y + sin(angle + (PI/2) * i) * distance
                    );
                break;
            }

            frameTime -= stepDur;
        }

        if (currentPatternDuration > dur!"seconds"(10))
        {
            if (++currentPattern >= 4)
                currentPattern = 0;

            currentPatternDuration = Duration.zero;
        }
    }

public:
    this(GameStateApplication application)
    {
        super(application);

        mUICamera = new OrthographicCamera(0, 640, 480, 0);
        mFont = AssetManager.load!Font("core://fonts/internal.fnt");
        mBackSoundSource = new AudioSampleSource(null);
        mBackSoundSource.buffer = AssetManager.load!Sound("res://menu/back.wav");
        mLogoTexture = AssetManager.load!Texture2D("core://textures/engine-logo.png");

        mBackground = new MenuBackground();

        mMainMenu = new VerticalMenu([
            VerticalMenu.Entry(tr("menu.creeps"), false, () {
                application.pushState(new CreepsMenuState(application));
            }),

            VerticalMenu.Entry(tr("menu.meshView"), false, () {
                application.pushState(new MeshDemo(application));
            }),

            VerticalMenu.Entry(tr("menu.terrain"), false, () {
                application.pushState(new TerrainDemo(application));
            }),

            VerticalMenu.Entry(tr("menu.collision"), false, () {
                application.pushState(new CollisionDemo(application));
            }),

            VerticalMenu.Entry(tr("menu.gamepad"), false, () {
                application.pushState(new GamepadDemo(application));
            }),

            VerticalMenu.Entry(tr("menu.particles"), false, () {
                application.pushState(new ParticlesDemo(application));
            }),

            VerticalMenu.Entry(tr("menu.crash"), false, () {
                mCrashOnNextFrame = true;
            }),

            VerticalMenu.Entry(tr("menu.rungc"), false, () {
                import core.memory : GC;

                Logger.client.log(LogLevel.info, "Running garbage collector...");
                GC.collect();
                AssetManager.cleanCache();
            }),

            VerticalMenu.Entry(tr("menu.quit"), false, () {
                ZyeWare.quit();
            })
        ], mFont);
    }

    override void tick(in FrameTime frameTime)
    {
        if (mCrashOnNextFrame)
            throw new Exception("This is a simulated crash.");

        processStarPattern(frameTime.deltaTime);
        mBackground.tick(frameTime.deltaTime);
    }

    override void draw(in FrameTime nextFrameTime)
    {
        Renderer2D.begin(mUICamera.projectionMatrix, mat4.identity);

        mBackground.draw();

        Renderer2D.drawRect(Rect2f(120.95, 60, 120.95 + 398.1, 60 + 115.2), Matrix4f.identity, Color.white, mLogoTexture);
        
        mMainMenu.draw(Vector2f(320, 200));

        Renderer2D.drawText(tr("menu.header"), mFont, Vector2f(320, 6), Color.white, Font.Alignment.center);
        Renderer2D.drawText(tr("menu.footer"), mFont, Vector2f(320, 480 - 4), Color.white, Font.Alignment.center | Font.Alignment.bottom);

        Renderer2D.end();
    }

    override void receive(in Event event)
    {
        if (auto actionEvent = cast(InputEventAction) event)
            mMainMenu.handleActionEvent(actionEvent);
    }

    override void onAttach(bool firstTime)
    {
        if (!firstTime)
            mBackSoundSource.play();
    }
}

