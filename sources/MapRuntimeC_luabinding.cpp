/*
** Lua binding: MapRuntimeC_luabinding
** Generated automatically by tolua++-1.0.92 on Fri Feb 22 12:59:11 2013.
*/

#include "MapRuntimeC_luabinding.h"
#include "CCLuaEngine.h"

using namespace cocos2d;




#include "MapRuntimeC.h"
using namespace GameLuabinding;

/* function to release collected object via destructor */
#ifdef __cplusplus


#endif


/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"CCNode");
 tolua_usertype(tolua_S,"MapRuntimeC");
 
}

/* method: create of class  MapRuntimeC */
#ifndef TOLUA_DISABLE_tolua_MapRuntimeC_luabinding_MapRuntimeC_create00
static int tolua_MapRuntimeC_luabinding_MapRuntimeC_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"MapRuntimeC",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   MapRuntimeC* tolua_ret = (MapRuntimeC*)  MapRuntimeC::create();
    int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"MapRuntimeC");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: tick of class  MapRuntimeC */
#ifndef TOLUA_DISABLE_tolua_MapRuntimeC_luabinding_MapRuntimeC_tick00
static int tolua_MapRuntimeC_luabinding_MapRuntimeC_tick00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"MapRuntimeC",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_istable(tolua_S,2,"LUA_TABLE",0,&tolua_err)) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !toluafix_istable(tolua_S,3,"LUA_TABLE",0,&tolua_err)) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  MapRuntimeC* self = (MapRuntimeC*)  tolua_tousertype(tolua_S,1,0);
  LUA_TABLE objectsLua = (  toluafix_totable(tolua_S,2,0));
  LUA_TABLE collsLua = (  toluafix_totable(tolua_S,3,0));
  float dt = ((float)  tolua_tonumber(tolua_S,4,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'tick'", NULL);
#endif
  {
     self->tick(objectsLua,collsLua,dt);
   
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'tick'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_MapRuntimeC_luabinding_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_constant(tolua_S,"kMapObjectClassIndexPath",kMapObjectClassIndexPath);
  tolua_constant(tolua_S,"kMapObjectClassIndexCrossPoint",kMapObjectClassIndexCrossPoint);
  tolua_constant(tolua_S,"kMapObjectClassIndexRange",kMapObjectClassIndexRange);
  tolua_constant(tolua_S,"kMapObjectClassIndexStatic",kMapObjectClassIndexStatic);
  tolua_constant(tolua_S,"kMapEventCollisionBegan",kMapEventCollisionBegan);
  tolua_constant(tolua_S,"kMapEventCollisionEnded",kMapEventCollisionEnded);
  tolua_constant(tolua_S,"kMapEventCollisionFire",kMapEventCollisionFire);
  tolua_cclass(tolua_S,"MapRuntimeC","MapRuntimeC","CCNode",NULL);
  tolua_beginmodule(tolua_S,"MapRuntimeC");
   tolua_function(tolua_S,"create",tolua_MapRuntimeC_luabinding_MapRuntimeC_create00);
   tolua_function(tolua_S,"tick",tolua_MapRuntimeC_luabinding_MapRuntimeC_tick00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_MapRuntimeC_luabinding (lua_State* tolua_S) {
 return tolua_MapRuntimeC_luabinding_open(tolua_S);
};
#endif

