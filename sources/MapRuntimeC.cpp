
#include "MapRuntimeC.h"
#include <math.h>
#include <stdio.h>
#include <string.h>

extern "C" {
#include "tolua_fix.h"
}

NS_MAP_GAME_LUABINDING_BEGIN

MapRuntimeC *MapRuntimeC::create(void)
{
    MapRuntimeC *runtime = new MapRuntimeC();
    runtime->autorelease();
    return runtime;
}

MapRuntimeC::MapRuntimeC(void)
: L(NULL)
{
    L = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
}

MapRuntimeC::~MapRuntimeC(void)
{
    CCLOG("~~ MapRuntimeC");
}

// checks = {evts, dists, colls}

LUA_TABLE MapRuntimeC::tick(LUA_TABLE objectsLua, LUA_TABLE collsLua, float dt)
{
    lua_pop(L, 1);                                                      /* L: objs colls */
    lua_newtable(L);                                                    /* L: objs colls evts */
    lua_newtable(L);                                                    /* L: objs colls evts dists */
    
    unsigned int eventIndex = 0;
    
	// calc static objects dist
    lua_pushnil(L);                                                     /* L: objs colls evts dists nil */
#if COCOS2D_DEBUG > 0 && kMapRuntimeDebug > 0
    CCLOG("----------------------------------------");
#endif
    while (lua_next(L, -5))                                             /* L: objs colls evts dists id1 obj1 */
    {
        bool skip = true;
        
        do
        {
            GET_OBJ_PROP_INT(classIndex1, "classIndex_");
            if (classIndex1 != kMapObjectClassIndexStatic) break;
            
            if (classIndex1 == kMapObjectClassIndexStatic)
            {
                GET_OBJ_PROP_BOOL(destroyed1, "destroyed_")
                if (destroyed1) break;
                
                GET_OBJ_PROP_BOOL(collisionEnabled1, "collisionEnabled_")
                if (!collisionEnabled1) break;
                
                GET_OBJ_PROP_INT(collisionLock1, "collisionLock_")
                if (collisionLock1 > 0) break;
                
#if COCOS2D_DEBUG > 0 && kMapRuntimeDebug > 0
                CCLOG("calc dist for static object %s, destroyed_: %d, collisionEnabled_: %d, collisionLock_: %d",
                      lua_tostring(L, -2),
                      destroyed1,
                      collisionEnabled1,
                      collisionLock1);
#endif
            }
            
            skip = false;
        } while (false);
        
        if (skip)
        {
            lua_pop(L, 1);                                              /* L: objs colls evts dists id1 */
            continue;
        }
        
        GET_OBJ_PROP_FLOAT(x1, "x_")
        GET_OBJ_PROP_FLOAT(y1, "y_")
        GET_OBJ_PROP_FLOAT(rx1, "radiusOffsetX_")
        GET_OBJ_PROP_FLOAT(ry1, "radiusOffsetY_")
        x1 += rx1;
        y1 += ry1;
        
        GET_OBJ_PROP_INT(campId1, "campId_")
        
        // dists[obj1] = {}
        lua_newtable(L);                                                /* L: objs colls evts dists id1 obj1 t */
        lua_pushvalue(L, -2);                                           /* L: objs colls evts dists id1 obj1 t obj1 */
        lua_pushvalue(L, -2);                                           /* L: objs colls evts dists id1 obj1 t obj1 t */
        lua_rawset(L, -6);                             /* dists[obj1] = t, L: objs colls evts dists id1 obj1 t */
        lua_remove(L, -2);                                              /* L: objs colls evts dists id1 dists[obj1] */
        
        // calc dists to other static objects and range objects
        lua_pushnil(L);                                                 /* L: objs colls evts dists id1 dists[obj1] nil */
        while (lua_next(L, -7))                                         /* L: objs colls evts dists id1 dists[obj1] id2 obj2 */
        {
            bool skip = true;
            
            do
            {
                if (lua_equal(L, -2, -4)) break;
                GET_OBJ_PROP_INT(classIndex2, "classIndex_");
                if (classIndex2 != kMapObjectClassIndexStatic && classIndex2 != kMapObjectClassIndexRange) break;
                
                if (classIndex2 == kMapObjectClassIndexStatic)
                {
                    GET_OBJ_PROP_BOOL(destroyed2, "destroyed_")
                    if (destroyed2) break;
                    
                    GET_OBJ_PROP_BOOL(collisionEnabled2, "collisionEnabled_")
                    if (!collisionEnabled2) break;
                    
                    GET_OBJ_PROP_INT(collisionLock2, "collisionLock_")
                    if (collisionLock2 > 0) break;
                    
                    GET_OBJ_PROP_INT(campId2, "campId_")
                    if (campId1 && campId1 == campId2) break;
                    
#if COCOS2D_DEBUG > 0 && kMapRuntimeDebug > 0
                    CCLOG("    -> static object %s, destroyed_: %d, collisionEnabled_: %d, collisionLock_: %d",
                          lua_tostring(L, -2),
                          destroyed2,
                          collisionEnabled2,
                          collisionLock2);
#endif
                }
                else
                {
#if COCOS2D_DEBUG > 0 && kMapRuntimeDebug > 0
                    CCLOG("    -> range %s", lua_tostring(L, -2));
#endif
                }
                
                GET_OBJ_PROP_FLOAT(x2, "x_")
                GET_OBJ_PROP_FLOAT(y2, "y_")
                GET_OBJ_PROP_FLOAT(rx2, "radiusOffsetX_")
                GET_OBJ_PROP_FLOAT(ry2, "radiusOffsetY_")
                
                float dx = (x2 + rx2) - x1;
                float dy = (y2 + ry2) - y1;
                float dist = sqrtf(dx * dx + dy * dy);
                
#if COCOS2D_DEBUG > 0 && kMapRuntimeDebug > 0
                CCLOG("       dist = %0.2f", dist);
#endif
                lua_pushnumber(L, dist);                                /* L: objs colls evts dists id1 dists[obj1] id2 obj2 dist1to2 */
                lua_rawset(L, -4);        /* dists[obj1][obj2] = dist1to2, L: objs colls evts dists id1 dists[obj1] id2 */
                skip = false;
            } while (false);
            
            if (skip)
            {
                lua_pop(L, 1);                                          /* L: objs colls evts dists id1 dists[obj1] id2 */
            }
        }                                                               /* L: objs colls evts dists id1 dists[obj1] */
        
        lua_pop(L, 1);                                                  /* L: objs colls evts dists id1 */
    }                                                                   /* L: objs colls evts dists */
    // complete calc dists
    
#if COCOS2D_DEBUG > 0 && kMapRuntimeDebug > 0
    CCLOG(" - - - - ");
#endif
    
    // ----------------------------------------
    
    // check collision and fire
    lua_pushnil(L);                                                     /* L: objs colls evts dists nil */
    while (lua_next(L, -2))                                             /* L: objs colls evts dists obj1 dists[obj1] */
    {
        lua_insert(L, -2);                                              /* L: objs colls evts dists dists[obj1] obj1 */
        
        GET_OBJ_PROP_BOOL(fireEnabled1,   "fireEnabled_")
        GET_OBJ_PROP_INT(fireLock1,       "fireLock_")
        GET_OBJ_PROP_FLOAT(fireRange1,    "fireRange_")
        GET_OBJ_PROP_FLOAT(fireCooldown1, "fireCooldown_")
        bool checkFire1 = fireEnabled1 && fireLock1 <= 0 && fireRange1 > 0 && fireCooldown1 <= 0;

        GET_OBJ_PROP_FLOAT(radius1, "radius_")

#if COCOS2D_DEBUG > 0 && kMapRuntimeDebug > 0
        lua_pushstring(L, "id_");
        lua_rawget(L, -2);
        const string id1 = string(lua_tostring(L, -1));
        lua_pop(L, 1);
        
        CCLOG("check fire and collision for static object %s, fireEnabled: %d, fireLock: %d, fireRange: %0.2f, fireCooldown: %0.2f",
              id1.c_str(), fireEnabled1, fireLock1, fireRange1, fireCooldown1);
#endif

        // add nil target
        float minTargetDist = 999999;
        lua_pushnil(L);                                                 /* L: objs colls evts dists dists[obj1] obj1 target */
        lua_pushvalue(L, -2);                                           /* L: objs colls evts dists dists[obj1] obj1 target obj1 */
        lua_rawget(L, -7);                                              /* L: objs colls evts dists dists[obj1] obj1 target colls[obj1] */
        
        if (!lua_istable(L, -1))
        {
            lua_pop(L, 1);                                              /* L: objs colls evts dists dists[obj1] obj1 target  */
            lua_newtable(L);                                            /* L: objs colls evts dists dists[obj1] obj1 target t */
            lua_pushvalue(L, -3);                                       /* L: objs colls evts dists dists[obj1] obj1 target t obj1 */
            lua_pushvalue(L, -2);                                       /* L: objs colls evts dists dists[obj1] obj1 target t obj1 t */
            lua_rawset(L, -9);                         /* colls[obj1] = t, L: objs colls evts dists dists[obj1] obj1 target colls[obj1] */
        }
                
        lua_pushnil(L);                                                 /* L: objs colls evts dists dists[obj1] obj1 target colls[obj1] nil */
        while (lua_next(L, -5))                                         /* L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 dist1to2 */
        {
            float dist1to2 = lua_tonumber(L, -1);
            lua_pop(L, 1);                                              /* L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 */
            
            GET_OBJ_PROP_FLOAT(radius2, "radius_")
            bool isCollision = dist1to2 - radius1 - radius2 <= 0;
            
            int event = 0;
            lua_pushvalue(L, -1);                                       /* L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 obj2 */
            lua_rawget(L, -3);                                          /* L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 colls[obj1][obj2] */
            if (isCollision && lua_isnil(L, -1))
            {
                event = kMapEventCollisionBegan;
            }
            else if (!isCollision && !lua_isnil(L, -1))
            {
                event = kMapEventCollisionEnded;
            }
            
            if (event != 0)
            {
                // update collision flag
                lua_pop(L, 1);                                          /* L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 */
                lua_pushvalue(L, -1);                                   /* L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 obj2 */
                if (event == kMapEventCollisionBegan)
                {
                    lua_pushboolean(L, 1);
                }
                else
                {
                    lua_pushnil(L);
                }
                lua_rawset(L, -4);               /* colls[obj1][obj2] = v, L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 */
                
                // add event, evt = {event[kMapEventCollisionBegan | kMapEventCollisionEnded], object1, object2}
                ++eventIndex;
                lua_newtable(L);                                        /* L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 t */
                lua_pushinteger(L, event);                              /* L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 t event */
                lua_rawseti(L, -2, 1);                    /* t[1] = event, L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 t */
                lua_pushvalue(L, -5);                                   /* L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 t obj1 */
                lua_rawseti(L, -2, 2);                    /* t[2] = obj1,  L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 t */
                lua_pushvalue(L, -2);                                   /* L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 t obj2 */
                lua_rawseti(L, -2, 3);                    /* t[3] = obj2,  L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 t */
                lua_rawseti(L, -8, eventIndex);        /* evts[index] = t, L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 */
            }
            else
            {
                lua_pop(L, 1);                                          /* L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 */
            }
            
            GET_OBJ_PROP_INT(classIndex2, "classIndex_")
            if (checkFire1 && classIndex2 == kMapObjectClassIndexStatic)
            {
                float targetDist = dist1to2 - fireRange1 - radius2;
                if (targetDist <= 0 && targetDist < minTargetDist)
                {
                    minTargetDist = targetDist;
                    // found target in fire range
                    lua_insert(L, -3);                                  /* L: objs colls evts dists dists[obj1] obj1 obj2 target colls[obj1] */
                    lua_pushvalue(L, -3);                               /* L: objs colls evts dists dists[obj1] obj1 obj2 target colls[obj1] obj2 */
                    lua_remove(L, -3);                   /* target = obj2, L: objs colls evts dists dists[obj1] obj1 target colls[obj1] obj2 */
                }
            }
            
#if COCOS2D_DEBUG > 0 && kMapRuntimeDebug > 0
            lua_pushstring(L, "id_");
            lua_rawget(L, -2);
            const string id2 = string(lua_tostring(L, -1));
            lua_pop(L, 1);
            
            CCLOG("    -> %s %s%s",
                  classIndex2 == kMapObjectClassIndexStatic ? "static object" : "range",
                  id2.c_str(),
                  event != 0 ? (event == kMapEventCollisionBegan ? ", collision began" : ",collision ended") : "");
#endif
        }                                                               /* L: objs colls evts dists dists[obj1] obj1 target colls[obj1] */
        
        lua_pop(L, 1);                                                  /* L: objs colls evts dists dists[obj1] obj1 target */
        
        if (!lua_isnil(L, -1))
        {
            // add event, evt = {event[kMapEventCollisionFire], obj1, target}
            ++eventIndex;
            lua_newtable(L);                                            /* L: objs colls evts dists dists[obj1] obj1 target t */
            lua_pushinteger(L, kMapEventCollisionFire);                 /* L: objs colls evts dists dists[obj1] obj1 target t event */
            lua_rawseti(L, -2, 1);                        /* t[1] = event, L: objs colls evts dists dists[obj1] obj1 target t */
            lua_pushvalue(L, -3);                                       /* L: objs colls evts dists dists[obj1] obj1 target t obj1 */
            lua_rawseti(L, -2, 2);                        /* t[2] = obj1,  L: objs colls evts dists dists[obj1] obj1 target t */
            lua_insert(L, -2);                                          /* L: objs colls evts dists dists[obj1] obj1 t target */
            lua_rawseti(L, -2, 3);                      /* t[3] = target,  L: objs colls evts dists dists[obj1] obj1 t */
            lua_rawseti(L, -5, eventIndex);            /* evts[index] = t, L: objs colls evts dists dists[obj1] obj1 */
        }
        else if (checkFire1)
        {
            // add event evt = {event[kMapEventCollisionNoTarget], obj1}
            ++eventIndex;
            lua_newtable(L);                                            /* L: objs colls evts dists dists[obj1] obj1 target t */
            lua_pushinteger(L, kMapEventCollisionNoTarget);             /* L: objs colls evts dists dists[obj1] obj1 target t event */
            lua_rawseti(L, -2, 1);                        /* t[1] = event, L: objs colls evts dists dists[obj1] obj1 target t */
            lua_pushvalue(L, -3);                                       /* L: objs colls evts dists dists[obj1] obj1 target t obj1 */
            lua_rawseti(L, -2, 2);                        /* t[2] = obj1,  L: objs colls evts dists dists[obj1] obj1 target t */
            lua_rawseti(L, -6, eventIndex);            /* evts[index] = t, L: objs colls evts dists dists[obj1] obj1 target */
            lua_pop(L, 1);                                              /* L: objs colls evts dists dists[obj1] obj1 */
        }
        else
        {
            lua_pop(L, 1);                                              /* L: objs colls evts dists dists[obj1] obj1 */
        }
        
        lua_insert(L, -2);                                              /* L: objs colls evts dists obj1 dists[obj1] */
        lua_pop(L, 1);                                                  /* L: objs colls evts dists obj1 */
    }                                                                   /* L: objs colls evts dists */
    
    lua_pop(L, 1);                                                      /* L: objs colls evts */
    return 1;
}

NS_MAP_GAME_LUABINDING_END
