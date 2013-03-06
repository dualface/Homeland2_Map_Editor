
#ifndef __MAP_RUNTIME_C_H_
#define __MAP_RUNTIME_C_H_

#include "cocos2d.h"
#include "CCLuaEngine.h"
#include <string>

extern "C" {
#include "lua.h"
}

#define NS_MAP_GAME_LUABINDING_BEGIN namespace GameLuabinding {
#define NS_MAP_GAME_LUABINDING_END }

using namespace std;
using namespace cocos2d;

NS_MAP_GAME_LUABINDING_BEGIN

#ifndef kMapRuntimeDebug
#define kMapRuntimeDebug                0
#endif

#define kMapObjectClassIndexPath        1
#define kMapObjectClassIndexCrossPoint  2
#define kMapObjectClassIndexRange       3
#define kMapObjectClassIndexStatic      4

#define kMapEventCollisionBegan         1
#define kMapEventCollisionEnded         2
#define kMapEventCollisionFire          3
#define kMapEventCollisionNoTarget      4


#define MAPRUNTIME_C_DISTS_TABLE_KEY        "dists"
#define MAPRUNTIME_C_COLLISIONS_TABLE_KEY   "collisions"

#define GET_OBJ_PROP_FLOAT(name, key)       lua_pushstring(L, key); \
                                            lua_rawget(L, -2); \
                                            float name = lua_tonumber(L, -1); \
                                            lua_pop(L, 1);

#define GET_OBJ_PROP_INT(name, key)         lua_pushstring(L, key); \
                                            lua_rawget(L, -2); \
                                            int name = lua_tointeger(L, -1); \
                                            lua_pop(L, 1);

#define GET_OBJ_PROP_BOOL(name, key)        lua_pushstring(L, key); \
                                            lua_rawget(L, -2); \
                                            bool name = lua_toboolean(L, -1); \
                                            lua_pop(L, 1);


class MapRuntimeC : public CCNode
{
public:
    static MapRuntimeC *create(void);
    ~MapRuntimeC(void);
    
    LUA_TABLE tick(LUA_TABLE objectsLua, LUA_TABLE collsLua, float dt);
    
private:
    MapRuntimeC(void);

    lua_State *L;
};

NS_MAP_GAME_LUABINDING_END

#endif // __MAP_RUNTIME_C_H_
