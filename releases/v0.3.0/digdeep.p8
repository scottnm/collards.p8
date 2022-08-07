pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- dispatch
a={
b=1,
c=2,
d=3,
}
function _init()
e()
f(a.b)
end
function _draw()
if g==a.b then
h()
elseif g==a.c then
i()
elseif g==a.d then
j()
end
end
function _update()
k=l()
if g==a.b then
m(k)
elseif g==a.c then
n(k)
elseif g==a.d then
o(k)
end
end
function f(p)
if p==a.b then
q()
elseif p==a.c then
r()
elseif p==a.d then
s()
end
g=p
end
function q()
u={
v=w(64,104),
x=w(-8,-14),
}
y(u,z.ba)
bb=nil
bc=31
bd=60
be=0.75
local bf=bg({
"the family plot...","they're taking it.","paving it for a new distribution center.",
"there's something buried there...","granddaddy left it for you.","it's with him\nunderground",
"good luck.","- granny ♥",
},5)
bh=bi(bf)
bj=#(bf)*2
bk=bj
bl={bm=194,bn=196,bo=198,bp=200,p=202}
bq={bl.bm,bl.bn,bl.bo,
bl.bm,bl.bp,bl.bp,bl.p}
br=nil
bs={
{bt="wait"},
{bt="dismiss_title",bu=75},
{bt="text_roll",bu=bk},
{bt="text_roll_hold",bu=60},
{bt="grave_entrance",bu=70},
{bt="wait_at_grave",bu=60,bv=true,bw=z.bx},
{bt="dig_at_grave",bu=36,bv=true,bw=z.by},
{bt="wait_at_stairs",bu=60,bv=true,bw=z.bx},
{bt="blackout",bu=30},
}
bz=1
ca={
cb(-130,0),
cb(-10,5),
cb(-90,5),
cb(-30,25),
cb(-120,30),
cb(-50,35),
}
end
cc=80
function cb(cd,ce)
return w(cd,ce+cc)
end
function cf(p)
cg(164,p.cd,p.ce,2,2,ch(p))
end
function ci(bo)
cg(206,bo.cd,bo.ce,2,4,ch(bo)*1.5)
end
function cj(p)
p.cd+=1.5*ch(p)
if p.cd>140 then p.cd=-10 end
end
function ch(p)
t=((p.ce-cc)/35)
return t*.5+.5
end
function ck(cl,cm,cn,co)
cp={cn=cn,cm=cm,co=co}
for bn=1,#cl do
if cl[bn].cn>cn then
add(cl,cp,bn)
return
end
end
add(cl,cp)
end
function m(k)
local cq=bs[bz]
if cq==nil then return end
y(u,cq.bw or z.ba)
if not cq.bv then
foreach(ca,cj)
if bb!=nil then
cj(bb)
end
end
if cq.bt=="dismiss_title"then
bc-=be
bd-=(be*2)
elseif cq.bt=="text_roll"then
bk-=1
end
cr=false
if br!=nil then
br-=1
cr=br==0
else
cr=k.cs or k.ct
end
if cr then
bz+=1
cu=bs[bz]
if cu!=nil then
br=nil
if cu.bu!=nil then
br=cu.bu
else
br=nil
end
if cu.bt=="grave_entrance"then
bb=cb(-10,8)
elseif cu.bt=="blackout"then
sfx(cv.cw)
end
else
f(a.c)
end
end
end
function cx()
for bn=1,15 do pal(bn,cy.cz) end
end
function da(color,cd,ce)
pal(cy.db,color)
local dc=15
for bn=0,(count(bq)-1) do
local t=flr(time()*30)+bn*4
local dd=sin(t%30/60)*3
cg(bq[bn+1],cd+bn*dc,ce+dd,2,2,1,false,false)
end
end
function de()
cx()
df(u,dg(u))
pal()
end
function h()
cls(cy.cz)
local cq=bs[bz]
if cq==nil or cq.bt=="blackout"then
return
end
rectfill(0,80,128,128,cy.dh)
di={}
ck(di,u,u.v.ce,de)
for p in all(ca) do
ck(di,p,p.ce,function() cf(p) end)
end
if bb!=nil then
ck(di,bb,bb.ce,function() ci(bb) end)
if cq.bt=="wait_at_stairs"then
spr(104,bb.cd-10,bb.ce+8,4,2,true)
rectfill(bb.cd-12,bb.ce+8,bb.cd+20,bb.ce+12,cy.dh)
end
end
for bp in all(di) do bp.co() end
print("press ❎/🅾️ to start",25,bd,cy.dj)
da(cy.dk,21,bc)
da(cy.db,22,bc+1)
if cq.bt=="text_roll"or cq.bt=="text_roll_hold"then
local dl=(bj-bk)/bj
dm(bh,dl,10,10,nil,6)
end
end
dn={
dp=1,
dq=2,
dr=3,
ds=4,
dt=5,
du=6,
dv=7,
dw=8,
dx=9,
}
dy={
dz=1,
ea=2,
eb=3,
}
ec={
ed=1,
ee=2,
ef=3,
eg=4,
eh=5,
ei=6,
ej=7,
ek=8,
}
el={
em=1,
en=2,
eo=3,
}
function ep()
return 32
end
function eq()
return 16
end
function er()
return 9
end
function es()
return 20
end
function et()
return 10
end
function eu()
return 5*60*30
end
function r()
ev=nil
ew=0
ex=nil
u={
ey=el.em,
v=w(0,0),
x=w(-8,-14),
ez={fa=3},
fb=0,
fc={},
}
fd=w(0,0)
fe=ff(fg,eu())
fh=fi(10)
fj(1,dn.dq)
fk={fl=0,fm=0,fn=0}
music(0,1000,7)
end
function s()
end
function n(k)
ew+=1
fe.fo(ew)
fp(fk)
local fq=false
if u.fr!=nil then
y(u,u.fr.fs)
if(u.ft.fu==2) and u.fr.fv!=nil then
u.fr.fv()
u.fr.fv=nil
end
if u.ft.fw>0 then
fx(u)
y(u,u.fr.fy)
u.fr=nil
end
fq=true
elseif u.fz!=nil then
y(u,u.fz.fs)
u.fz.ga.fo()
if u.fz.ga.gb() then
u.fz=nil
end
fq=true
elseif gc!=nil then
gc.gd.fo()
if gc.gd.gb() then
local ge=gc.ge
local gf=gc.gg
gc=nil
fj(ge,gf)
end
fq=true
elseif u.gh!=nil then
y(u,u.gh.fs)
u.gh.gi.fo()
if u.gh.gi.gb() then
u.gh=nil
fj(1,dn.dq)
end
fq=true
end
if not fq then
gj(k)
end
local gk={}
for gl in all(gm) do
gl.fo()
if gl.gb() then
add(gk,gl)
end
for bp in all(gl.gn()) do
local go=gp(gq,bp)
for gr in all(go) do
gr.gs.gt=true
end
if(u.gh==nil) and(gu(u,bp)) then
gv(u,gq)
end
end
end
for gl in all(gk) do
del(gm,gl)
end
if ew>=eu() then
gw(false)
end
end
function gx(gy,gz,ha)
gy.fz={
fs=z.hb,
hc=gz,
ga=hd(45),
}
for he,cm in pairs(ha or{}) do
gy.fz[he]=cm
end
local hf=nil
if gz==dy.dz then
hf="bomb. ❎ to use"
elseif gz==dy.ea then
hf="page fragment"
elseif gz==dy.eb then
hf="granddaddy's book"
else
assert(false)
end
hg("got: "..hf,"item",60)
sfx(cv.hh)
end
function hi(ge,hj,hk)
gc={
gd=hd(15),
ge=ge,
gg=hj,
}
sfx(hk)
end
function gj(k)
hl(k)
hm(k)
local hn=k.ho and k.ct
if hn then
u.fr={
fs=hp(u),
fy=u.ft.hq}
fx(u)
end
local hr=hs(gq,u)
if hr!=nil then
local ht=gq.hu[hr]
if hn then
local hv=function()
sfx(cv.hw)
ht.gs.gt=true
hx(ht.gs)
end
u.fr.fv=hv
elseif ht.gs.gt then
hx(ht.gs)
u.hy=ht
elseif ht.gs.hz then
u.ey=el.eo
ht.gs.hz=false
gx(u,dy.eb)
u.hy=ht
end
u.ia=ht
end
local ib=k.ic and k.cs
if ib then
if u.fb>0 then
u.fb-=1
add(gm,id(u.v,ie))
end
end
end
function ie()
sfx(cv.ig)
end
function gv(gy,map)
local ih="died."
if gy.ey==el.eo then
local ii=ij(map)
map.hu[ii].gs.hz=true
u.ey=el.en
ih=ih.." dropped book."
end
gy.gh={
fs=ik(gy),
gi=hd(60),
}
hg(ih,"death",60)
sfx(cv.il)
end
function hx(gs)
if gs==u.hy.gs then
return
end
if gs.type==dn.dr then
hi(gq.im+1,dn.dq,cv.cw)
elseif gs.type==dn.dq then
if u.ey==el.em then
hg("can't leave until i find it.","warning",90)
elseif u.ey==el.en then
if gq.im!=1 then
hi(gq.im-1,dn.dr,cv.io)
else
hg("can't leave. i lost the book.","warning",90)
end
elseif u.ey==el.eo then
if gq.im!=1 then
hi(gq.im-1,dn.dr,cv.io)
else
gw(true)
end
else
assert(false)
end
elseif gs.type==dn.ds then
gv(u,gq)
elseif gs.type==dn.du then
u.fb+=1
gx(u,dy.dz)
gs.type=dn.dp
elseif gs.type==dn.dv then
add(u.fc,gs.ip)
gx(u,dy.ea,{ip=gs.ip})
gs.type=dn.dp
gs.ip=nil
elseif gs.hz then
u.ey=el.eo
gs.hz=false
gx(u,dy.eb)
end
end
function fg()
sfx(cv.iq)
end
function ir(gy)
local hq=gy.ft.hq
return(hq==z.is or
hq==z.ba or
hq==z.bx or
hq==z.it or
hq==z.iu or
hq==z.iv)
end
function hp(gy)
if ir(gy) then
return z.by
else
return z.iw
end
end
function ik(gy)
if ir(gy) then
return z.ix
else
return z.iy
end
end
function iz(gy)
return w(gy.v.cd-64,gy.v.ce-64)
end
function ja(gy,jb)
local jc=iz(gy)
local jd=je(jc,jb)
if jd<=jf(es()) then
return
end
local jg=jh(jb,jc)
local ji=sqrt(jd)
jg.cd/=ji
jg.ce/=ji
jg.cd*=es()
jg.ce*=es()
jj=jk(gy.v,jg)
jb.cd=jj.cd-64
jb.ce=jj.ce-64
end
function o(k)
fe.fo(ew)
if ex.jl=="scroll_timer"then
ex.jm+=1
fe.jn(0,0.5)
if ex.jm==120 then
ex.jl="brief_blink"
ex.jo=hd(120)
end
elseif ex.jl=="brief_blink"then
ex.jo.fo()
if ex.jo.gb() then
ex.jl="display_game_over_text"
ex.jp=0.8
ex.jq=0
ex.jr=(#ex.js)/ex.jp
end
elseif ex.jl=="display_game_over_text"then
ex.jq+=1
local jt=ex.jq>=ex.jr
if jt and(k.ic or k.ho) then
f(a.b)
end
end
end
function i()
cls(cy.ju)
ja(u,fd)
camera(fd.cd,fd.ce);
for gr in all(gq.hu) do
local jv=jw(gr.gs)
if jv!=nil then
spr(128,gr.v.cd-ep()/2,gr.v.ce,4,2,false)
spr(jv,gr.v.cd-ep()/2,gr.v.ce-eq()/2,4,2,false)
if gr.gs.gt then
if(gr.gs.type==dn.dp) and(gr.gs.jx!=nil) then
jy(gr.v,gr.gs.jx)
elseif gr.gs.type==dn.du then
jz(gr.v)
elseif gr.gs.type==dn.dv then
ka(gr.v,gr.gs.ip)
elseif gr.gs.type==dn.dw then
kb(88,gr.v.cd,gr.v.ce,2,1)
end
end
if gr.gs.hz then
kc(gr.v,gr.gs.type==dn.dw)
end
end
end
if gu(u,u.ia) then
kd(u.ia)
end
df(u,dg(u))
if u.fz!=nil then
local ke=jh(u.v,w(0,16))
if u.fz.hc==dy.dz then
jz(ke)
elseif u.fz.hc==dy.ea then
ka(ke,u.fz.ip)
elseif u.fz.hc==dy.eb then
kc(ke,false)
end
end
for gl in all(gm) do
gl.kf()
end
camera(0,0)
print("Level: "..gq.im,0,120,cy.dj)
if ev!=nil then
kg(ev.kh,ev.ki,ev.kj)
ev.gd.fo()
if ev.gd.gb() then
ev=nil
end
end
kk(fk)
jz(w(4,111))
print(":"..u.fb,8,110,cy.dj)
kl(u)
fe.kf(ew)
end
function j()
cls(cy.ju)
if ex.jl!="display_game_over_text"then
ja(u,fd)
camera(fd.cd,fd.ce);
local km=dg(u)
df(u,km)
kl(u)
camera(0,0)
print("Level: "..gq.im,0,120,cy.dj)
fe.kf(ew)
else
local dl=(ex.jp*ex.jq)/ex.jr
dm(ex.js,dl,10,10,nil,17)
kl(u)
end
end
function fp(kn)
ko=0.04
local kp=false
kn.fn-=1
if kn.fn<=0 then
kp=true
kn.fn=15
end
if kp then
local kq=0
for gr in all(gq.hu) do
local kr=gr.gs.type
if kr==dn.du or kr==dn.dv then
local ks=sqrt(je(u.v,gr.v));
local kt=ku(0,1-(ks/48),1)
kq=max(kq,kt)
end
end
kn.fm=kq
end
if kn.fl>kn.fm then
kn.fl=max(kn.fl-ko,kn.fm)
else
kn.fl=min(kn.fl+ko,kn.fm)
end
end
function kk(kn)
kv={cd=2,ce=20,kw=8,kx=50}
rect(kv.cd,kv.ce,kv.cd+kv.kw,kv.ce+kv.kx,cy.dj)
local ky=0
if rnd(1)>0.7 then
ky=(rnd(2)-1)/kv.kx
end
local kz=ku(0.05,1-kn.fl+ky,0.95)
local la=kv.ce+(kv.kx*kz)
line(kv.cd,la,kv.cd+(kv.kw*.60),la)
lb=5
for bn=1,lb do
local lc=flr(kv.kx/(lb+1))*bn
pset(kv.cd+kv.kw-1,kv.ce+lc,cy.dj)
end
end
function kl(gy)
ld=le()
camera(0,0)
local lf=8
for bn=1,#u.fc do
local lg=bn*lf
ka(w(120-lg,120),u.fc[bn])
end
if gy.ey==el.eo then
kc(w(120,120),false)
end
lh(ld)
end
function li(rect,kh)
local lj=#kh
local lk=4*lj
local ll=6
local lm=rect.cd+(rect.ln/2)-(lk/2)
local lo=rect.ce+(rect.lp/2)-(ll/2)
return w(lm,lo+1)
end
function jy(v,jx)
local lq=nil
local lr=false
local lt=false
if jx==ec.ef then
lq=134
elseif jx==ec.eg then
lq=133
lt=true
elseif jx==ec.eh then
lq=132
lt=true
elseif jx==ec.ei then
lq=133
lr=true
lt=true
elseif jx==ec.ej then
lq=134
lr=true
elseif jx==ec.ek then
lq=133
lr=true
elseif jx==ec.ed then
lq=132
else
lq=133
end
kb(lq,v.cd,v.ce,1,1,lr,lt)
end
function jz(v)
kb(74,v.cd,v.ce,1,1)
end
function ka(v,lu)
kb(lu,v.cd,v.ce,1,1)
end
function kc(v,lv)
local lw=0
if lv then
lw=4
end
kb(72,v.cd,v.ce-lw,1,1)
end
function hg(kh,lx,ly)
local ki,kj=nil,nil
if lx=="warning"then
ki,kj=cy.dk,cy.lz
elseif lx=="item"then
ki,kj=cy.ma,cy.dk
elseif lx=="death"then
ki,kj=cy.mb,cy.mc
end
ev={
kh=kh,
ki=ki,
kj=kj,
gd=hd(ly),
}
end
function kg(kh,ki,kj)
ld=le()
camera(0,0)
local md={cd=0,ce=98,ln=128,lp=10}
rectfill(md.cd,md.ce,md.cd+md.ln,md.ce+md.lp,kj)
rect(md.cd+1,md.ce+1,md.cd+md.ln-2,md.ce+md.lp-1,ki)
local me=li(md,kh)
print(kh,me.cd,me.ce,ki)
lh(ld)
end
function fi(mf)
local mg={}
for bn=1,(mf-1) do
local mh=min((bn+1),er())
add(mg,mi(bn,mh))
end
for map in all(mg) do
local mj=ij(map)
map.hu[mj].gs=mk(true,dn.dq)
map.ml=ij(map)
map.hu[map.ml].gs=mk(false,dn.dr)
end
for map in all(mg) do
local mm=flr(map.mn*map.mn*0.30)
local mo=mp({map},mm)
for mq in all(mo) do
map.hu[mq.mr].gs=mk(false,dn.ds)
end
end
local ms=10
local mt=mp(mg,ms)
for mu in all(mt) do
mu.map.hu[mu.mr].gs=mk(false,dn.du)
end
local mv={172,173,188,189}
local mw=0
local mx=et()
local my=mp(mg,mx)
for mz in all(my) do
mz.map.hu[mz.mr].gs=mk(false,dn.dv)
mz.map.hu[mz.mr].gs.ip=mv[mw+1]
mw=((mw+1)%#mv)
end
for map in all(mg) do
local na=map.hu[map.ml].v
for gr in all(map.hu) do
if gr.gs.type==dn.dp then
local jg=jh(na,gr.v)
local nb=atan2(jg.cd,-1*jg.ce)
local nc=nb*360
local jx=nil
if nc<22.5 then
jx=ec.ef
elseif nc<67.5 then
jx=ec.eg
elseif nc<112.5 then
jx=ec.eh
elseif nc<157.5 then
jx=ec.ei
elseif nc<202.5 then
jx=ec.ej
elseif nc<247.5 then
jx=ec.ek
elseif nc<292.5 then
jx=ec.ed
elseif nc<337.5 then
jx=ec.ee
else
jx=ec.ef
end
gr.gs.jx=jx
end
end
end
local nd=mi(mf,er())
local ne=flr(#nd.hu/2)+1
nd.hu[ne].gs=mk(true,dn.dw)
nd.hu[ne].gs.hz=true
local nf=ij(nd)
nd.hu[nf].gs=mk(true,dn.dq)
for gr in all(nd.hu) do
if gr.gs.type==dn.dp then
gr.gs=mk(true,dn.dx)
end
end
add(mg,nd)
return mg
end
function mi(im,ng)
local nh={}
nh.im=im
nh.mn=ng
nh.hu={}
local ni=nh.mn*2-1
local nj=ni+4
local mr=1
for nk=1,nj do
local nl=flr((nj+1)/2)
local nm=(nk-nl)*eq()/2
local nn=nil
if nk<=nl then
nn=nk
else
nn=2*nl-nk
end
for no=1,nn do
local gs=nil
local np=(no==1) or(no==nn)
if np then
gs=mk(true,dn.dt)
else
gs=mk(false,dn.dp)
end
local nq=
-1*((nn/2)*ep())
+(ep()/2)
+((no-1)*ep())
local gr={
mr=mr,
gs=gs,
v=w(
nr()/2+nq,
nr()/2+nm),
ez={fa=4}
}
add(nh.hu,gr)
mr+=1
end
end
return nh
end
function mk(gt,ns)
return{gt=gt,type=ns}
end
function ij(map)
return mp({map},1)[1].mr
end
function mp(mg,nt)
local nu=0
local nv={}
for map in all(mg) do
for gr in all(map.hu) do
if gr.gs.type==dn.dp then
add(nv,{map=map,mr=gr.mr})
nu+=1
end
end
end
local nw={}
for bn=1,nt do
local nx=ny(1,nu)
local nz=nv[nx]
nv[nx]=nv[nu]
nv[nu]=nil
add(nw,nz)
end
return nw
end
function jw(gs)
if gs.gt then
local kr=gs.type
if kr==dn.dp then
return 160
elseif kr==dn.dq then
return 108
elseif kr==dn.dr then
return 104
elseif kr==dn.ds then
return 76
elseif kr==dn.dt then
return nil
elseif kr==dn.du then
return 160
elseif kr==dn.dv then
return 160
elseif kr==dn.dw then
return 140
elseif kr==dn.dx then
return 136
else
return nil
end
else
assert(kr!=dn.dw and kr!=dn.dx)
return 96
end
end
function fj(ge,hj)
gq=fh[ge]
local oa=nil
for gr in all(gq.hu) do
if gr.gs.type==hj then
oa=gr
break
end
end
assert(oa!=nil)
u.v=ob(oa.v)
u.ia=oa
u.hy=oa
fd=iz(u)
y(u,z.oc)
gm={}
end
function hl(k)
local od=0.70710678118
local oe=0
local of=0
if k.og then
if k.oh then
oe=-2*od
of=-1*od
elseif k.oi then
oe=-2*od
of=od
else
oe=-2
of=0
end
elseif k.oj then
if k.oh then
oe=2*od
of=-1*od
elseif k.oi then
oe=2*od
of=od
else
oe=2
of=0
end
elseif k.oh then
oe=0
of=-1
elseif k.oi then
oe=0
of=1
else
return
end
local ok=1.0
oe*=ok
of*=ok
local ol=ob(u.v)
local om={}
add(om,w(oe,of))
if oe!=0 then
add(om,w(oe,0))
end
if of!=0 then
add(om,w(0,of))
end
for jn in all(om) do
u.v=jk(ol,jn)
local hu=gp(gq,u)
local on=true
for gr in all(hu) do
if gr.gs.type==dn.dt then
on=false
break
end
end
if on then
return
end
end
u.v=ol
end
function hm(k)
local fs=nil
if k.og then
if k.oh then
fs=z.it
elseif k.oi then
fs=z.iv
else
fs=z.ba
end
elseif k.oj then
if k.oh then
fs=z.oo
elseif k.oi then
fs=z.op
else
fs=z.oq
end
elseif k.oh then
fs=z.os
elseif k.oi then
fs=z.ot
else
if u.ft.hq==z.ba then
fs=z.is
elseif u.ft.hq==z.oq then
fs=z.ou
elseif u.ft.hq==z.os then
fs=z.ov
elseif u.ft.hq==z.ot then
fs=z.oc
elseif u.ft.hq==z.it then
fs=z.bx
elseif u.ft.hq==z.oo then
fs=z.ow
elseif u.ft.hq==z.iv then
fs=z.iu
elseif u.ft.hq==z.op then
fs=z.ox
else
fs=u.ft.hq
end
end
y(u,fs)
end
function dg(oy)
return jk(oy.v,oy.x)
end
function hs(map,oz)
for gr in all(gp(map,oz)) do
if gu(oz,gr) then
return gr.mr
end
end
return nil
end
function gu(pa,pb)
local pc=jf(pa.ez.fa+pb.ez.fa)
local jd=je(pa.v,pb.v)
return jd<=pc
end
function gp(map,oz)
hu={}
for gr in all(map.hu) do
if pd(gr,oz) then
add(hu,gr)
end
end
return hu
end
function pd(gr,oz)
local pe={
{ln=12,lp=12},
{ln=18,lp=9},
{ln=26,lp=5},
}
local pf={
v=w(
oz.v.cd-oz.ez.fa,
oz.v.ce-oz.ez.fa),
ln=(oz.ez.fa+oz.ez.fa),
lp=(oz.ez.fa+oz.ez.fa),
}
for pg in all(pe) do
pg.v=w(gr.v.cd-(pg.ln/2),gr.v.ce-(pg.lp/2))
if ph(pf,pg) then
return true
end
end
return false
end
function ph(pi,pj)
local pk=pi.v.cd>=(pj.v.cd+pj.ln)
local pl=pj.v.cd>=(pi.v.cd+pi.ln)
if pk or pl then
return false
end
local pm=pi.v.ce>=(pj.v.ce+pj.lp)
local pn=pj.v.ce>=(pi.v.ce+pi.lp)
if pm or pn then
return false
end
return true
end
function kd(gr)
local po=gr.v.cd
local pp=gr.v.ce-1
local pq={
w(po-ep()/2,pp),
w(po,pp-eq()/2),
w(po+ep()/2,pp),
w(po,pp+eq()/2),
}
line(pq[1].cd,pq[1].ce,pq[2].cd,pq[2].ce,cy.dj)
line(pq[2].cd,pq[2].ce,pq[3].cd,pq[3].ce,cy.dj)
line(pq[3].cd,pq[3].ce,pq[4].cd,pq[4].ce,cy.dj)
line(pq[4].cd,pq[4].ce,pq[1].cd,pq[1].ce,cy.dj)
end
function id(v,ie)
local self={
pr="Countdown",
ps=z.pt,
pu=hd(32),
pv={},
pw={},
v=ob(v),
ie=ie
}
function px(v)
local od=0.70710678118
local py=w(2*od,-1*od)
local pz=w(-2*od,-1*od)
local qa=w(2*od,1*od)
local qb=w(-2*od,1*od)
function qc(lq,v)
return{lq=lq,v=v,ez={fa=3}}
end
local qd=10
return{
qc(0,ob(v)),
qc(-8,jk(v,qe(pz,1*qd))),
qc(-16,jk(v,qe(pz,2*qd))),
qc(-24,jk(v,qe(pz,3*qd))),
qc(-8,jk(v,qe(py,1*qd))),
qc(-16,jk(v,qe(py,2*qd))),
qc(-24,jk(v,qe(py,3*qd))),
qc(-8,jk(v,qe(qb,1*qd))),
qc(-16,jk(v,qe(qb,2*qd))),
qc(-24,jk(v,qe(qb,3*qd))),
qc(-8,jk(v,qe(qa,1*qd))),
qc(-16,jk(v,qe(qa,2*qd))),
qc(-24,jk(v,qe(qa,3*qd))),
}
end
local fo=function()
if self.pr=="Countdown"then
y(self,self.ps)
if self.ft.fw>0 then
self.pr="Explode"
self.pv=px(self.v)
end
elseif self.pr=="Explode"then
self.pu.fo()
if self.pu.gb() then
self.pr="Done"
self.pv={}
self.pw={}
end
for bp in all(self.pv) do
bp.lq+=1
if bp.lq==1 then
add(self.pw,bp)
self.ie()
elseif bp.lq==13 then
del(self.pw,bp)
end
end
else
end
end
local gb=function()
return self.pr=="Done"
end
local kf=function()
if self.pr=="Countdown"then
df(self,w(self.v.cd-4,self.v.ce-4))
elseif self.pr=="Explode"then
for bp in all(self.pv) do
local qf=2
local dc=(qf-1)*((6-abs(bp.lq-6))/6)+1
if bp.lq<0 then
elseif bp.lq<4 then
cg(90,bp.v.cd,bp.v.ce,1,1,dc)
elseif bp.lq<8 then
cg(91,bp.v.cd,bp.v.ce,1,1,dc)
elseif bp.lq<12 then
cg(90,bp.v.cd,bp.v.ce,1,1,dc)
else
end
end
else
end
end
local gn=function()
return self.pw
end
return{
fo=fo,
kf=kf,
gb=gb,
gn=gn
}
end
function qg()
return"you were unable to make\nyour way to the bottom\nof the grave in time.\n\nyour family's most\ncherished heirloom is\nlost. gone forever.\n\nthis is unacceptable.\nyou'll have to try again.\n\nx/c - to reset"
end
function qh(qi,qj)
local kh="you made it back with the book. a brown book stitched together with strong thread and thick brown pages. a family heirloom."
if qi==0 then
kh=kh.." opening the book you realize several pages are missing. maybe they're back down in the grave. at least you saved the book. in another life, maybe you could find those pages.\n\nx/c - to reset"
elseif qi<qj then
local qk=nil
if qi==1 then
qk="page"
else
qk="pages"
end
local ql=nil
if qi==(qj-1) then
ql="is still 1 page missing. maybe the last page is"
else
ql="are still "..(qj-qi).." pages missing. maybe the rest are"
end
kh=kh.." setting the "..qi.." recovered "..qk.." in the book you realize there "..ql.." back down in the grave. it's not whole, but there's comfort in what you have. in another life, maybe you could recover the rest.\n\nx/c - to reset"
else
kh=kh.." setting all "..qj.." pages you found below in the book, you realize the book is complete.\nit reveals its story to you.\n\nthe first page reads:\n\"collard greens. wash greens 7 times. tear 'em up. throw 'em in a large pot. cover greens with water.  add onion, garlic, some peppa, spoonful of vinegar, and one ham hock. cover the pot and bring to a boil.\n\nthe book's previous owner was a driven, young man who desperately wanted to raise his daughter well. a self-taught cook, he learned that the collard recipe was full of love, flavor, and the secret ingredient, perseverance. a giant sunday pot of collards became tradition, providing them with greens for the whole week.\"\nx/c - to reset"
end
return bi(kh)
end
function gw(qm)
ex={
jl="scroll_timer",
jm=0,
}
if qm then
ex.js=qh(#u.fc,et())
else
ex.js=qg()
end
fe.qn(true)
f(a.d)
music(-1,1000)
end
cv={
hw=1,
il=2,
iq=3,
ig=21,
cw=5,
io=6,
hh=7,
}
function qo(qp,qq,qr,flip)
return{
qp=qp,
qs=count(qp),
qq=qq,
qr=qr,
flip=flip,
}
end
function fx(oy)
oy.ft.qt=0
oy.ft.fu=0
oy.ft.fw=0
end
function y(oy,fs)
oy.ft=oy.ft or{qt=0,fu=0,qu=0,fw=0}
local ft=oy.ft
ft.qt+=1
local qv=ft.qt%(30/fs.qq)==0
if qv then
ft.fu+=1
if ft.fu>=fs.qs then
ft.fu=0
ft.fw+=1
end
elseif ft.fu>=fs.qs then
ft.fu=0
end
local lq=fs.qp[ft.fu+1]
ft.qu=lq
ft.flip=fs.flip
ft.qr=fs.qr
ft.hq=fs
end
function df(oy,qw)
local ft=oy.ft
spr(ft.qu,qw.cd,qw.ce,ft.qr,ft.qr,ft.flip)
end
function e()
z={
oc=qo({34},10,2,false),
ot=qo({32,34,36},10,2,false),
ov=qo({40},10,2,false),
os=qo({38,40,42},10,2,false),
ou=qo({66},10,2,false),
oq=qo({64,66,68},10,2,false),
is=qo({66},10,2,true),
ba=qo({64,66,68},10,2,true),
ow=qo({8},10,2,false),
oo=qo({6,8,10},10,2,false),
ox=qo({2},10,2,false),
op=qo({0,2,4},10,2,false),
bx=qo({8},10,2,true),
it=qo({6,8,10},10,2,true),
iu=qo({2},10,2,true),
iv=qo({0,2,4},10,2,true),
iw=qo({12,12,14},5,2,false),
by=qo({12,12,14},5,2,true),
ix=qo({70,70,224},5,2,true),
iy=qo({70,70,224},5,2,false),
hb=qo({46},1,2,false),
pt=qo({74,74,74,74,74,74,74,75,74,74,75,74,74,75,74},15,1,false),
}
end
function hd(qx)
local self={
qp=0,
qx=qx,
}
local fo=function()
if self.qp<self.qx then
self.qp+=1
end
end
local gb=function()
return self.qp>=self.qx
end
local qy=function()
return self.qp/self.qx
end
return{
qy=qy,
fo=fo,
gb=gb
}
end
function ff(qz,ra)
local self={
rb=false,
rc=0,
rd=25,
re=nil,
rf=false,
qz=qz,
ra=ra,
rg=42,
rh=10,
}
local ri=function(rj)
return rj/self.ra
end
local rk=function(rj)
if rj==0 or rj==self.ra then
return false
end
local rl=flr(self.ra/24)
local rm=10
return(rj%rl)<rm
end
local qn=function(rb)
self.rb=rb
end
local rn=function()
if not self.rb then
return false
end
return self.rc>=self.rd
end
local ro=function(rp)
local rq=flr(rp/60)
local rr=rp%60
local rs=flr(rr)
local rt=(rr&0x0000.ffff)*60
local ru=flr(rt)
return{rv=rq,rw=rs,rx=ru}
end
local ry=function()
self.rz=true
end
local sa=function(rj)
if self.rb then
self.rc+=1
if self.rc>(self.rd*1.5) then
self.rc=0
end
end
local sb=rk(rj)
if sb and(not self.rf) then
self.qz()
end
self.rf=sb
end
local sc=function(rj)
if rn() then
return
end
local sd=cy.dj
local se=self.rg
local sf=self.rh
if self.rf then
sd=cy.sg
se+=ny(-1,1)
sf+=ny(-1,1)
end
local sh=ri(rj)
local si=(24*60)
local sj=(1-sh)*si
local time=ro(sj)
local sk=sl(time.rv,2).."H:"..sl(time.rw,2).."M:"..sl(time.rx,2).."S"
print(sk,se+1,sf+1,cy.sm)
print(sk,se,sf,sd)
end
local sn=function(cd,ce)
self.rg+=cd
self.rh+=ce
end
return{
qn=qn,
fo=sa,
kf=sc,
jn=sn,
}
end
cy={
cz=0,
mc=1,
db=2,
ma=3,
dh=4,
sm=5,
so=6,
dj=7,
mb=8,
sp=9,
sg=10,
sq=11,
sr=12,
lz=13,
ss=14,
dk=15,
}
function nr()
return 128
end
function ny(st,su)
return flr(rnd(su-st))+st
end
function ku(st,sv,su)
return mid(st,sv,su)
end
function l()
return{
og=btn(0),
sw=btnp(0),
oj=btn(1),
sx=btnp(1),
oh=btn(2),
sy=btnp(2),
oi=btn(3),
sz=btnp(3),
ho=btn(4),
ct=btnp(4),
ic=btn(5),
cs=btnp(5),
ta=btnp()!=0,
}
end
function sl(tb,ln)
local tc=tostr(tb)
repeat
tb=flr(tb/10)
ln-=1
until(ln<=0) or(tb<=0)
while(ln>0) do
tc="0"..tc
ln-=1
end
return tc
end
function jf(cd)
return cd*cd
end
function je(td,te)
return jf(td.cd-te.cd)+jf(td.ce-te.ce)
end
function le()
return{cd=peek2(0x5f28),ce=peek2(0x5f2a)}
end
function lh(tf)
camera(tf.cd,tf.ce)
end
function w(cd,ce)
return{cd=cd,ce=ce}
end
function ob(cm)
return w(cm.cd,cm.ce)
end
function jk(tg,th)
return w(tg.cd+th.cd,tg.ce+th.ce)
end
function jh(tg,th)
return w(tg.cd-th.cd,tg.ce-th.ce)
end
function qe(cm,tc)
return w(cm.cd*tc,cm.ce*tc)
end
function kb(lq,cd,ce,ti,tj,lr,lt)
lr=lr or false
lt=lt or false
spr(lq,cd-(ti*8/2),ce-(tj*8/2),ti,tj,lr,lt)
end
function cg(lq,cd,ce,ti,tj,dc,lr,lt)
lr=lr or false
lt=lt or false
local tk=(lq%16)*8
local tl=flr(lq/16)*8
local tm=ti*8
local tn=tj*8
local to=dc*tm
local tp=dc*tn
local rg=(cd-to/2)
local rh=(ce-tp/2)
sspr(tk,tl,tm,tn,rg,rh,to,tp,lr,lt)
end
function dm(kh,t,cd,ce,tf,tq)
tf=tf or cy.dj
local tr=1
local ts=flr((#kh)*t)
local tt=0
for bn=1,ts do
local tu=ts-(bn-1)
local tv=sub(kh,tu,tu)
if tv=="\n"then
tt+=1
if tt>=tq then
tr=tu+1
break
end
end
end
print(sub(kh,tr,ts),cd,ce,tf)
end
function bi(kh)
local bi=""
local tw=0
while tw<#kh do
local ts=min(tw+1+25,#kh)
local tx=nil
if ts==#kh then
tx=sub(kh,tw+1)
else
local ty=nil
for bn=(tw+1),ts do
if sub(kh,bn,bn)=="\n"then
ty=bn
end
end
if ty!=nil then
tx=sub(kh,tw+1,ty-1).." "
else
while sub(kh,ts,ts)!=" "do
ts-=1
end
tx=sub(kh,tw+1,ts)
end
end
if bi==""then
bi=tx
else
bi=bi.."\n"..tx
end
tw+=#tx
end
return bi
end
function bg(tz,ua)
local tc=""
for bn=1,(#tz-1) do
t=tz[bn]
tc=tc..t
for ub=1,ua do tc=tc.." "end
tc=tc.."\n\n"
end
return tc..tz[#tz]
end
__gfx__
00000000000000000000055555500000000000000000000000000000000000000000055555500000000000000000000000000000000000000000000000000000
00000555555000000000555555550000000005555550000000000555555000000000555555550000000005555550000000550555555000000220055555500000
00005555555500000005555555555000000055555555000000005555555500000005111115555000000055555555000005515555555500000000d1d555550000
00055555555550000005555999955000000555555555500000051115555550000005155511555000000555111155500055515555555550000051d1d555555000
00055559999550000005559999595000000555599995500000015551155550000001555551555000000551555515500055515555555550000551ddd559955000
00055599995950000005599599595000000555999959500000055555155550000001555551555000000551555515500055501555599950005551585599995000
00055995995950000005599599990000000559959959500000055555115550000001555551590000000551555515500005505555999900005555185995990000
00055995999900000000599999960000000559959999000000055555515900000000555555660000000555555559000000005559959900005550585995990000
00005999999660000000669999666000000059999996600000055555566660000006666666666000000065555556600000009999959900000550599699900000
00996699996699000009966666669000000666999966690000966666666699000099666666699000000966666666690000000999999000000000099966600000
09996666666999000009966666669000000999666666999009996666666699000099666666699000000966666666999000006666666600000000669966660000
09906666666990000009966666669000000999666666099009906666666690000099666666699000000966666666099000006699666600000000666666660000
00006666cccc00000000cccccccc00000000cccc6666000000006666cccc00000000cccccccc00000000cccc6666000000000c999cc0ddd000000cccccc00000
0000cccccc5500000000c5500c5500000000c55ccccc00000000ccccccc500000000cc500cc500000000cccccccc000000000cc99888d11000000cccc1100000
0000c550066600000000666006660000000066600c5500000000cc50066600000000666006660000000066600cc50000000005555dd0d220000005555dd00000
00006660000000000000000000000000000000000666000000006660000000000000000000000000000000000666000000000666600022220000066660002220
00000000000000000000055555550000000000000000000000000000000000000000055555500000000000000000000000000555555000000000055555550000
00000555555500000000555555555000000005555555000000000555555000000000555555550000000005555550000000005555555550000000555555555000
00005555555550000005555555555500000055555555500000005555555500000005555115555000000055555555000000005555999550000005555555555500
00055555555555000005555999955500000555555555550000055551115550000005551551555000000555111555500000515559999550000005555999955500
00055559999555000005559999995500000555599995550000055515551550000005515555155000000551555155500005551595599950000005559999995500
00055599999955000005595999595500000555999999550000055155555150000005515555155000000515555515500055551599999900000005595999595500
00055959995955000000595999595000000559599959550000055155555150000000995555990000000515555515500055515999999900000099595999595990
0000595999595000000009999999000000005959995950000000995555590000000066555566000000009555559900005550599999960dd00099099999990990
00000999999900000000669999966000000009999999600000066655555660000006666666666000000665555566600009900699966dddd00099669999966990
00996699999660000006666666669000000966999996690000966666666699000009666666669000009966666666690009996666666dd0000006666666666900
09996666666699000009666666669000000999666666999009996666666699000009666666669000009966666666999000999666666000000000666666660000
099066666669990000096666666690000009996666660990099066666666900000096666666690000009666666660990000006666660005d0000666666660000
00006666ccc990000000cccccccc00000000cccc6666000000006666cccc00000000cccccccc00000000cccc6666000000000cccccc1156d0000cccccccc0000
0000ccccc555000000005550055500000000555ccccc00000000cccccccc00000000ccc00ccc00000000cccccccc000000000ccccccc156d0000555005550000
0000555006660000000066600666000000006660055500000000ccc0066600000000666006660000000066600ccc00000000001111ccc56d0000666006660000
00006660000000000000000000000000000000000666000000006660000000000000000000000000000000000666000000000000000cc5600000000000000000
00005555555000000000000000000000000055555550000000000000000000000d99999000000000000000000000000000000000000000444400000000000000
00515555555550000000055555500000005155555555500000000000000000000d9ddd9000888800000900000009000000000000000044444444000000000000
05515555555550000051555555550000055155555555500000000000000000000d99999000099000000090000000900000000000004444999944440000000000
55515555555550000551555555555000555155555555500000000000005555500d93339000888800001111000088880000000000444499999999444400000000
55551555999950005551555555555000555515559999500000000000055555550d93b39008881880011611100886888000000044499999948999944444000000
55505559999900005555155559995000555055599999000000000000055555550d93b39008188180016111100868888000004444999888888888899444440000
05505559959900005550555599990000055055599599000000000000000511100d99b990088188800111111008888880004444888888a8888888888888444400
00009999959900000550555995990000000099999599000000000000955155500d999990088888800011110000888800444488858888888888a8888888844444
00dd69999990000000009999959900000000099999900dd0001cc669955555550000000000000000000000000008800044444888888888888a8a888888844444
00dd666666600990000009999990000000996666666dddd0d1ccc66995555555000000000000000000000000008998000044444488888aa88888888884444400
0000666669999990000066666666000000999666666dd000dcccc66999555555000000000000000000099000089aa98000004444444888888888884444440000
0000c6666699900000006699666600000099066666600000d6ccc969599555550000666666660000009aa90089aaaa98000000444444888a8888444444000000
065ccccccc15d00000000c99ccc0000000990cccccc00560d65c9969559955550005dddddddd6000009aa90089aaaa9800000000444444888844444400000000
065ccccc1115d00000000c99c11000000000dccccccc05600650996999995555005dddddddddd60000099000089aa98000000000004444448444440000000000
065ccc0000000000000005555dd000000000d51111ccc56006509900999955500005dddddddd5000000000000889980000000000000044444444000000000000
065000000000000000000666600000000000d500000cc56000000000055555000000555555550000000000000008800000000000000000444400000000000000
00000000000000444400000000000000000000000000004444000000000000000000000000000044440000000000000000000000000000444400000000000000
00000000000044444444000000000000000000000000444444440000000000000000000000004444444400000000000000000000000044222222222220000000
000000000044444444444400000000000000000000444422244444000000000000000000004444444244440000000000000000000044222ddd22666222220000
00000000444444424444444400000000000000004444222222244444000000000000000044444422222244440000000000000000442226622dd22222ddd20000
00000044444444442444444444000000000000444422222222222444440000000000004444422222222222444400000000000044442d226622dddd2dddd20000
00004444444444444444444444440000000044444222222222222224444400000000444442222222222222244444000000004422222ddd2266222d2dddd20000
0044444424444444444444444444440000444444222222dddddd222244444400004444222222222222222222244444000044442d266222dd2266222ddd224400
4444444244444444444444444444444444444442dddddddddd2dddd22444444444444222666222d6622ddd22224444444444442dd2266222dd222dddd2224444
444444444444444444444424444444444444444dddddddddd2d2ddddd444444444444442dd6662ddd662ddd22444444444444422ddd2266222dd2dddd2244444
0044444444444444244444444444440000444444ddddd22dddddddd44444440000444444222d6662ddd622dd444444000044444422ddd2266622ddd224444400
0000444444444442424444444444000000004444444ddddddddd444444440000000044444422dd6622dd622444440000000044444222ddd2222dd22444440000
00000044444444444444444444000000000000444444ddd2dd44444444000000000000444444222d66224444440000000000004444422dd2ddd2244444000000
0000000044444444444444440000000000000000444444ddd44444440000000000000000444444222dd44444000000000000000044444222d224444400000000
00000000004444444444440000000000000000000044444444444400000000000000000000444444244444000000000000000000004444422444440000000000
00000000000044444444000000000000000000000000444444440000000000000000000000004444444400000000000000000000000044444444000000000000
00000000000000444400000000000000000000000000004444000000000000000000000000000044440000000000000000000000000000444400000000000000
220000000000000000000000000000dd0000000000000000000000000000000000000000000000dddd0000000000000000000000000000444400000000000000
2222000000000000000000000000dddd00022000000000000000200000000000000000000000dd6666dd00000000000000000000000044443444000000000000
22222200000000000000000000dddddd002222000002222000002200000000000000000000dd66dddd66dd000000000000000000004444444444440000000000
222222220000000000000000dddddddd0222222000002220022222200000000000000000dd66dd66dddd66dd00000000000000004444344444b4444400000000
2222222222000000000000dddddddddd00022000000220200222222000000000000000dd66dddddddddddd66dd00000000000044444b4444b44444b444000000
22222222222200000000dddddddddddd000220000022000000002200000000000000dd66dddddddddddd5ddd66dd000000004444844444444444434344440000
222222222222220000dddddddddddddd0002200002200000000020000000000000dd66dddd5ddddddddddddddd66dd0000444e48a8444444444444444e444400
0022222222222222dddddddddddddd0000000000000000000000000000000000dd66d6dd55dddddd5ddddddd6ddd66dd4444eae48444434444444444eae44444
0000222222222222dddddddddddd0000000000000000000000000000000000005555dddddddddddddddddddddddd555544444eb4b34444444444b444be444444
0000002222222222dddddddddd00000000000000000000000000000000000000005555dddddddddddddddddddd555500004443b4b444b4448444443b34444400
0000000022222222dddddddd000000000000000000000000000000000000000000005555dddd6ddddddd5ddd555500000000444b4443b448a844444b44440000
0000000000222222dddddd0000000000000000000000000000000000000000000000005555dddddddd5ddd555500000000000044444444438444434444000000
0000000000002222dddd00000000000000000000000000000000000000000000000000005555dddddddd5555000000000000000044443444b344444400000000
0000000000000022dd000000000000000000000000000000000000000000000000000000005555dddd555500000000000000000000444444b444440000000000
00000000000000000000000000000000000000000000000000000000000000000000000000005555555500000000000000000000000044444444000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000055550000000000000000000000000000444400000000000000
00000000000000444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008000000008800
00000000000044444444000000000000000000000000000000000000000000000000000000000000000000000000000000999990000999000008800000088000
00000000004444555444440000000000000055555555000000000000000000000000000000000000000000000000000000955590000959000088880000888800
00000000444455555554444400000000000566666666650000000000000000000000000000000000000000000000000000999990000999000089980000899800
000000444455555ffffff444440000000056666666666600000000000000000000000000000000000000000000000000009dd900009dd900089aa980089aa980
0000444455fffffffffffff44444000005666666666666600000000000000000000000000000000000000000000000000099990000999900089aa980089aa980
004444455fffffffffffffff44444400056655556655566000000000000000000000000000000000000000000000000000999000099990000089980000899800
444444ffffffffffffffffffff444444056666666666666000000000000000000000000000000000000000000000000000000000000000000008800000088000
444444fffffffffffffffffff4444444056666555555566000000000000000000000000000000000000000000000000000000000000000000000808000080008
0044444fffffffffffffffff44444400056666666666666000000000000000000000000000000000000000000000000000000000000009000008800000088000
000044444ffffffffffffff444440000056665555666666000000000000000000000000000000000000000000000000000999900099999000088880000888800
0000004444ffffffffff4444440000000566666666666660000000000000000000000000000000000000000000000000009dd900099dd9000089980000899800
000000004444ffffff4444440000000005665565555556600000000000000000000000000000000000000000000000000099999000999900089aa980089aa980
000000000044444ff4444400000000000566666666666660000000000000000000000000000000000000000000000000009ddd90009dd900089aa980089aa980
00000000000044444444000000000000056666666666666000000000000000000000000000000000000000000000000000999990009999000089980000899800
00000000000000444400000000000000056666666666666000000000000000000000000000000000000000000000000000000000000000000008800000088000
00022222222000000002222222200000000222222222200000000222222220000002222222222000000222222222000000000000000000000000000000000000
00022222222200000002222222220000000222222222200000002222222222000002222222222000000222222222200000000000000000000000000000000000
00022000002220000002200000222000000000022000000000022200000022000002200000000000000220000002220000000000000000000000555555550000
00022000000220000002200000022000000000022000000000022000000000000002200000000000000220000000220000000000000000000005666666666500
00022002200022000002200000002200000000022000000000220000000000000002200000000000000220000000220000000000000000000056666666666600
00022002220022000002200000002200000000022000000000220000000000000002200000000000000220000000220000000000000000000566666666666660
00022002220022000002200000002200000000022000000000220000000000000002200000000000000220000000220000000000000000000556666666666660
00022002220022000002200000002200000000022000000000220000002222000002222222200000000220000002220000000000000000000056666666666600
00022002220022000002200000002200000000022000000000220000002222000002222222200000000222222222200000000000000000000005666666666000
00022002220022000002200000002200000000022000000000220000000022000002200000000000000222222222000000000000000000000005566666660000
00022002220022000002200000002200000000022000000000220000000022000002200000000000000220000000000000000000000000000000566666660000
00022002200022000002200000002200000000022000000000220000000022000002200000000000000220000000000000000000000000000005566666660000
00022000000220000002200000022000000000022000000000222000000022000002200000000000000220000000000000000000000000000055666666666000
00022000002220000002200000222000000000022000000000022200000022000002200000000000000220000000000000000000000000000556666666666600
00022222222200000002222222220000000222222222200000002222222222000002222222222000000220000000000000000000000000000566666666666660
00022222222000000002222222200000000222222222200000000222222220000002222222222000000220000000000000000000000000000566666666666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566666666666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566666666666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566666666666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566666666666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566666666666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566666666666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566655566555660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566666666666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566665555555660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566666666666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566655556666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566666666666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566556555555660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566666666666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566666666666660
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000566666666666660

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300001065009650056500a550025500d5500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002a650286502565021650334501d650186502b75026750284500f6501f7501c7501a75018750056501775016750176501665013650145500f6500c650120500d750070500b75001650001500975008750
30030000115502a0503805000000000000000000000000000f5503805000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000266005670026600066002660006600067000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9c0c0000186750c6350c6000c67516600136000c67510600106000c6000c6050c6050c6050c60513600116000e6001760013600106001660013600116000c6050c6050c6050c6000060000600006000000000000
9c0c00000c675186350c600186751660018600186750c6000c6050c6050c6050c605186050c6050e6001760013600106001660013600116000c6050c6050c6050c60000600006000060000000000000000000000
100500001c05317055190501e05023050200502a050000002a040000002a030000002a01000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00180020010630170000000010631f633000000000000000010630000000000000001f633000000000000000010630000000000010631f633000000000000000010630000001063000001f633000000000000000
01180020071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155051550c155081550c155051550c155081550c155051550c155081550c155051550c137081550c155
01180020071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1370c1550f155
01180020081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155071550e1550a1550e155071550e1550a1550e155071550e1550a1550e155071550e1370a1550e155
011800201305015050160501605016050160551305015050160501605016050160551605015050160501a05018050160501805018050180501805018050180550000000000000000000000000000000000000000
011800201305015050160501605016050160551305015050160501605016050160551605015050160501a0501b0501b0501b0501b0501b0501b0501b0501b0550000000000000000000000000000000000000000
011800201b1301a1301b1301b1301b1301b1351b1301a1301b1301b1301b1301b1351b1301a1301b1301f1301a130181301613016130161301613016130161350000000000000000000000000000000000000000
011800201b1301a1301b1301b1301b1301b1351b1301a1301b1301b1301b1301b1351b1301a1301b1301f1301d1301d1301d1301d1301d1301d1301d1301d1350000000000000000000000000000000000000000
01180020081550f1550c1550f155081550f1550c1550f155081550f1550c1550f155081550f1550c1550f1550a155111550e155111550a155111550e155111550a155111550e155111550a155111550e15511155
011800202271024710267102671026710267152271024710267102671026710267152671024710267102971027710267102471024710247102471024710247150000000000000000000000000000000000000000
01180020227102471026710267102671026715227102471026710267102671026715267102471026710297102b7102b7102b7102b7102b7102b7102b7102b7150000000000000000000000000000000000000000
011800202b720297202b7202b7202b7202b7252b720297202b7202b7202b7202b7252b720297202b7202e72029720277202672026720267202672026720267250000000000000000000000000000000000000000
011800202b720297202b7202b7202b7202b7252b720297202b7202b7202b7202b7252b720297202b7202e7202e7202e7202e7202e7202e7202e7202e7202e7250000000000000000000000000000000000000000
00040000176301d6302163025630286302b6302e630306302d6302663022630136300463000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
01 09454308
00 0a424308
00 090c4344
00 0a0d4344
00 090c1108
00 0a0d1208
00 0b0e4344
00 100f4344
00 0b0e1308
02 100f1408

