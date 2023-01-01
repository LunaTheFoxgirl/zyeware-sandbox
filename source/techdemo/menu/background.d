module techdemo.menu.background;

import std.container.slist;
import std.container.dlist;
import std.datetime;
import std.math : sin, cos, fmod;

import zyeware.common;
import zyeware.rendering;

private static immutable Vector2f screenCenter = Vector2f(320, 240);

class MenuBackground
{
protected:
    struct Star
    {
        Vector2f position;
        Duration lifeTime;
    }

    Texture2D mStarTexture;
    Texture2D mBackdrop;

    Star[2000] mStars;
    DList!size_t mFreeStars;
    SList!size_t mActiveStars;

public:
    this()
    {
        mStarTexture = AssetManager.load!Texture2D("res://menu/menuStar.png");
        mBackdrop = AssetManager.load!Texture2D("res://menu/background.png");

        for (size_t i; i < mStars.length; ++i)
            mFreeStars.insertBack(i);
    }

    void spawn(float x, float y)
    {
        if (mFreeStars.empty)
            return;

        immutable size_t nextFreeStar = mFreeStars.front;
        mFreeStars.removeFront();

        mStars[nextFreeStar].position = Vector2f(x, y);
        mStars[nextFreeStar].lifeTime = Duration.zero;
        mActiveStars.insertFront(nextFreeStar);
    }

    void tick(Duration frameTime)
    {
        immutable float delta = frameTime.toFloatSeconds;

        size_t[] starIndicesToRemove;

        foreach (size_t starIndex; mActiveStars)
        {
            Vector2f* position = &mStars[starIndex].position;

            mStars[starIndex].lifeTime += frameTime;

            immutable float lifeTimeSecs = mStars[starIndex].lifeTime.toFloatSeconds;
            immutable float alpha = 1 - lifeTimeSecs / 10f;

            position.x += (position.x - screenCenter.x) * 1.5 * delta;
            position.y += (position.y - screenCenter.y) * 1.5 * delta;

            if (position.x < 0 || position.x > screenCenter.x * 2 || position.y < 0
                || position.y > screenCenter.y * 2 || alpha <= 0)
                starIndicesToRemove ~= starIndex;
        }

        foreach (size_t starIndex; starIndicesToRemove)
        {
            mActiveStars.linearRemoveElement(starIndex);
            mFreeStars.insertBack(starIndex);
        }
    }

    void draw()
    {
        immutable float upTime = ZyeWare.upTime.toFloatSeconds;
        Renderer2D.drawRect(Rect2f(-10, -10, 660, 500), Vector2f(cos(upTime * 0.5f) * 10f, sin(upTime) * 10f),
            Vector2f(1), Color.white, mBackdrop);

        foreach (size_t starIndex; mActiveStars)
        {
            immutable float lifeTimeSecs = mStars[starIndex].lifeTime.toFloatSeconds;
            immutable float alpha = 1 - lifeTimeSecs / 10f;

            Renderer2D.drawRect(Rect2f(-4, -4, 4, 4), mStars[starIndex].position, Vector2f(1),
                Color(fmod(lifeTimeSecs, 1), 1, 1, alpha).toRGB(), mStarTexture);
        }
    }
}