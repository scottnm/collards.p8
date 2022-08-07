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
f()
g(a.b)
end
function _draw()
if h==a.b then
i()
elseif h==a.c then
j()
elseif h==a.d then
k()
end
end
function _update()
l=m()
if h==a.b then
n(l)
elseif h==a.c then
o(l)
elseif h==a.d then
p(l)
end
end
function g(q)
if q==a.b then
r()
elseif q==a.c then
s()
elseif q==a.d then
u()
end
h=q
end
function r()
v={
w=x(64,104),
y=x(-8,-14),
}
z(v,ba.bb)
bc=nil
bd=31
be=60
bf=0.75
local bg=bh({
"the family plot...","they're taking it.","paving it for a new distribution center.",
"there's something buried there...","granddaddy left it for you.","it's with him\nunderground",
"good luck.","- granny ♥",
},5)
bi=bj(bg)
bk=#(bg)*2
bl=bk
bm={bn=194,bo=196,bp=198,bq=200,q=202}
br={bm.bn,bm.bo,bm.bp,
bm.bn,bm.bq,bm.bq,bm.q}
bs=nil
bt={
{bu="wait"},
{bu="dismiss_title",bv=75},
{bu="text_roll",bv=bl},
{bu="text_roll_hold",bv=60},
{bu="grave_entrance",bv=70},
{bu="wait_at_grave",bv=60,bw=true,bx=ba.by},
{bu="dig_at_grave",bv=36,bw=true,bx=ba.bz},
{bu="wait_at_stairs",bv=60,bw=true,bx=ba.by},
{bu="blackout",bv=30},
}
ca=1
cb={
cc(-130,0),
cc(-10,5),
cc(-90,5),
cc(-30,25),
cc(-120,30),
cc(-50,35),
}
end
cd=80
function cc(ce,cf)
return x(ce,cf+cd)
end
function cg(q)
ch(164,q.ce,q.cf,2,2,ci(q))
end
function cj(bp)
ch(206,bp.ce,bp.cf,2,4,ci(bp)*1.5)
end
function ck(q)
q.ce+=1.5*ci(q)
if q.ce>140 then q.ce=-10 end
end
function ci(q)
t=((q.cf-cd)/35)
return t*.5+.5
end
function cl(cm,cn,co,cp)
cq={co=co,cn=cn,cp=cp}
for bo=1,#cm do
if cm[bo].co>co then
add(cm,cq,bo)
return
end
end
add(cm,cq)
end
function n(l)
local cr=bt[ca]
if cr==nil then return end
z(v,cr.bx or ba.bb)
if not cr.bw then
foreach(cb,ck)
if bc!=nil then
ck(bc)
end
end
if cr.bu=="dismiss_title"then
bd-=bf
be-=(bf*2)
elseif cr.bu=="text_roll"then
bl-=1
end
cs=false
if bs!=nil then
bs-=1
cs=bs==0
else
cs=l.ct or l.cu
end
if cs then
ca+=1
cv=bt[ca]
if cv!=nil then
bs=nil
if cv.bv!=nil then
bs=cv.bv
else
bs=nil
end
if cv.bu=="grave_entrance"then
bc=cc(-10,8)
elseif cv.bu=="blackout"then
sfx(cw.cx)
end
else
g(a.c)
end
end
end
function cy()
for bo=1,15 do pal(bo,cz.da) end
end
function db(color,ce,cf)
pal(cz.dc,color)
local dd=15
for bo=0,(count(br)-1) do
local t=flr(time()*30)+bo*4
local de=sin(t%30/60)*3
ch(br[bo+1],ce+bo*dd,cf+de,2,2,1,false,false)
end
end
function df()
cy()
dg(v,dh(v))
pal()
end
function i()
cls(cz.da)
local cr=bt[ca]
if cr==nil or cr.bu=="blackout"then
return
end
rectfill(0,80,128,128,cz.di)
dj={}
cl(dj,v,v.w.cf,df)
for q in all(cb) do
cl(dj,q,q.cf,function() cg(q) end)
end
if bc!=nil then
cl(dj,bc,bc.cf,function() cj(bc) end)
if cr.bu=="wait_at_stairs"then
spr(104,bc.ce-10,bc.cf+8,4,2,true)
rectfill(bc.ce-12,bc.cf+8,bc.ce+20,bc.cf+12,cz.di)
end
end
for bq in all(dj) do bq.cp() end
print("press ❎/🅾️ to start",25,be,cz.dk)
db(cz.dl,21,bd)
db(cz.dc,22,bd+1)
if cr.bu=="text_roll"or cr.bu=="text_roll_hold"then
local dm=(bk-bl)/bk
dn(bi,dm,10,10,nil,6)
end
end
dp={
dq=1,
dr=2,
ds=3,
dt=4,
du=5,
dv=6,
dw=7,
dx=8,
dy=9,
}
dz={
ea=1,
eb=2,
ec=3,
}
ed={
ee=1,
ef=2,
eg=3,
eh=4,
ei=5,
ej=6,
ek=7,
el=8,
}
em={
en=1,
eo=2,
ep=3,
}
function eq()
return 32
end
function er()
return 16
end
function es()
return 9
end
function et()
return 20
end
function eu()
return 10
end
function ev()
return 5*60*30
end
function s()
ew=nil
ex=0
ey=nil
v={
ez=em.en,
w=x(0,0),
y=x(-8,-14),
fa={fb=3},
fc=0,
fd={},
}
fe=x(0,0)
ff=fg(fh,ev())
fi=fj(10)
fk(1,dp.dr)
fl={fm=0,fn=0,fo=0}
music(0,1000,7)
end
function u()
end
function o(l)
ex+=1
ff.fp(ex)
fq(fl)
local fr=false
if v.fs!=nil then
z(v,v.fs.ft)
if(v.fu.fv==2) and v.fs.fw!=nil then
v.fs.fw()
v.fs.fw=nil
end
if v.fu.fx>0 then
fy(v)
z(v,v.fs.fz)
v.fs=nil
end
fr=true
elseif v.ga!=nil then
z(v,v.ga.ft)
v.ga.gb.fp()
if v.ga.gb.gc() then
v.ga=nil
end
fr=true
elseif gd!=nil then
gd.ge.fp()
if gd.ge.gc() then
local gf=gd.gf
local gg=gd.gh
gd=nil
fk(gf,gg)
end
fr=true
elseif v.gi!=nil then
z(v,v.gi.ft)
v.gi.gj.fp()
if v.gi.gj.gc() then
v.gi=nil
fk(1,dp.dr)
end
fr=true
end
if not fr then
gk(l)
end
local gl={}
for gm in all(gn) do
gm.fp()
if gm.gc() then
add(gl,gm)
end
for bq in all(gm.go()) do
local gp=gq(gr,bq)
for gs in all(gp) do
gs.gt.gu=true
end
if(v.gi==nil) and(gv(v,bq)) then
gw(v,gr)
end
end
end
for gm in all(gl) do
del(gn,gm)
end
if ex>=ev() then
gx(false)
end
end
function gy(gz,ha,hb)
gz.ga={
ft=ba.hc,
hd=ha,
gb=he(45),
}
for hf,cn in pairs(hb or{}) do
gz.ga[hf]=cn
end
local hg=nil
if ha==dz.ea then
hg="bomb. ❎ to use"
elseif ha==dz.eb then
hg="page fragment"
elseif ha==dz.ec then
hg="granddaddy's book"
else
assert(false)
end
hh("got: "..hg,"item",60)
sfx(cw.hi)
end
function hj(gf,hk,hl)
gd={
ge=he(15),
gf=gf,
gh=hk,
}
sfx(hl)
end
function gk(l)
hm(l)
hn(l)
local ho=l.hp and l.cu
if ho then
v.fs={
ft=hq(v),
fz=v.fu.hr}
fy(v)
end
local hs=ht(gr,v)
if hs!=nil then
local hu=gr.hv[hs]
if ho then
local hw=function()
sfx(cw.hx)
hu.gt.gu=true
hy(hu.gt)
end
v.fs.fw=hw
elseif hu.gt.gu then
hy(hu.gt)
v.hz=hu
elseif hu.gt.ia then
v.ez=em.ep
hu.gt.ia=false
gy(v,dz.ec)
v.hz=hu
end
v.ib=hu
end
local ic=l.id and l.ct
if ic then
if v.fc>0 then
v.fc-=1
add(gn,ie(v.w,ig))
end
end
end
function ig()
sfx(cw.ih)
end
function gw(gz,map)
local ii="died."
if gz.ez==em.ep then
local ij=ik(map)
map.hv[ij].gt.ia=true
v.ez=em.eo
ii=ii.." dropped book."
end
gz.gi={
ft=il(gz),
gj=he(60),
}
hh(ii,"death",60)
sfx(cw.im)
end
function hy(gt)
if gt==v.hz.gt then
return
end
if gt.type==dp.ds then
hj(gr.io+1,dp.dr,cw.cx)
elseif gt.type==dp.dr then
if v.ez==em.en then
hh("can't leave until i find it.","warning",90)
elseif v.ez==em.eo then
if gr.io!=1 then
hj(gr.io-1,dp.ds,cw.ip)
else
hh("can't leave. i lost the book.","warning",90)
end
elseif v.ez==em.ep then
if gr.io!=1 then
hj(gr.io-1,dp.ds,cw.ip)
else
gx(true)
end
else
assert(false)
end
elseif gt.type==dp.dt then
gw(v,gr)
elseif gt.type==dp.dv then
v.fc+=1
gy(v,dz.ea)
gt.type=dp.dq
elseif gt.type==dp.dw then
add(v.fd,gt.iq)
gy(v,dz.eb,{iq=gt.iq})
gt.type=dp.dq
gt.iq=nil
elseif gt.ia then
v.ez=em.ep
gt.ia=false
gy(v,dz.ec)
end
end
function fh()
sfx(cw.ir)
end
function is(gz)
local hr=gz.fu.hr
return(hr==ba.it or
hr==ba.bb or
hr==ba.by or
hr==ba.iu or
hr==ba.iv or
hr==ba.iw)
end
function hq(gz)
if is(gz) then
return ba.bz
else
return ba.ix
end
end
function il(gz)
if is(gz) then
return ba.iy
else
return ba.iz
end
end
function ja(gz)
return x(gz.w.ce-64,gz.w.cf-64)
end
function jb(gz,jc)
local jd=ja(gz)
local je=jf(jd,jc)
if je<=jg(et()) then
return
end
local jh=ji(jc,jd)
local jj=sqrt(je)
jh.ce/=jj
jh.cf/=jj
jh.ce*=et()
jh.cf*=et()
jk=jl(gz.w,jh)
jc.ce=jk.ce-64
jc.cf=jk.cf-64
end
function p(l)
ff.fp(ex)
if ey.jm=="scroll_timer"then
ey.jn+=1
ff.jo(0,0.5)
if ey.jn==120 then
ey.jm="brief_blink"
ey.jp=he(120)
end
elseif ey.jm=="brief_blink"then
ey.jp.fp()
if ey.jp.gc() then
ey.jm="display_game_over_text"
ey.jq=0.8
ey.jr=0
ey.js=(#ey.jt)/ey.jq
end
elseif ey.jm=="display_game_over_text"then
ey.jr+=1
local ju=ey.jr>=ey.js
if ju and(l.ct or l.cu) then
g(a.b)
end
end
end
function j()
cls(cz.jv)
jb(v,fe)
camera(fe.ce,fe.cf);
for gs in all(gr.hv) do
local jw=jx(gs.gt)
if jw!=nil then
spr(128,gs.w.ce-eq()/2,gs.w.cf,4,2,false)
spr(jw,gs.w.ce-eq()/2,gs.w.cf-er()/2,4,2,false)
if gs.gt.gu then
if(gs.gt.type==dp.dq) and(gs.gt.jy!=nil) then
jz(gs.w,gs.gt.jy)
elseif gs.gt.type==dp.dv then
ka(gs.w)
elseif gs.gt.type==dp.dw then
kb(gs.w,gs.gt.iq)
elseif gs.gt.type==dp.dx then
kc(88,gs.w.ce,gs.w.cf,2,1)
end
end
if gs.gt.ia then
kd(gs.w,gs.gt.type==dp.dx)
end
end
end
if gv(v,v.ib) then
ke(v.ib)
end
dg(v,dh(v))
if v.ga!=nil then
local kf=ji(v.w,x(0,16))
if v.ga.hd==dz.ea then
ka(kf)
elseif v.ga.hd==dz.eb then
kb(kf,v.ga.iq)
elseif v.ga.hd==dz.ec then
kd(kf,false)
end
end
for gm in all(gn) do
gm.kg()
end
camera(0,0)
print("Level: "..gr.io,0,120,cz.dk)
if ew!=nil then
kh(ew.ki,ew.kj,ew.kk)
ew.ge.fp()
if ew.ge.gc() then
ew=nil
end
end
kl(fl)
ka(x(4,111))
print(":"..v.fc,8,110,cz.dk)
km(v)
ff.kg(ex)
end
function k()
cls(cz.jv)
if ey.jm!="display_game_over_text"then
jb(v,fe)
camera(fe.ce,fe.cf);
local kn=dh(v)
dg(v,kn)
km(v)
camera(0,0)
print("Level: "..gr.io,0,120,cz.dk)
ff.kg(ex)
else
local dm=(ey.jq*ey.jr)/ey.js
dn(ey.jt,dm,10,10,nil,17)
km(v)
end
end
function fq(ko)
kp=0.04
local kq=false
ko.fo-=1
if ko.fo<=0 then
kq=true
ko.fo=15
end
if kq then
local kr=0
for gs in all(gr.hv) do
local ks=gs.gt.type
if ks==dp.dv or ks==dp.dw then
local kt=sqrt(jf(v.w,gs.w));
local ku=kv(0,1-(kt/48),1)
kr=max(kr,ku)
end
end
ko.fn=kr
end
if ko.fm>ko.fn then
ko.fm=max(ko.fm-kp,ko.fn)
else
ko.fm=min(ko.fm+kp,ko.fn)
end
end
function kl(ko)
kw={ce=2,cf=20,kx=8,ky=50}
rect(kw.ce,kw.cf,kw.ce+kw.kx,kw.cf+kw.ky,cz.dk)
local kz=0
if rnd(1)>0.7 then
kz=(rnd(2)-1)/kw.ky
end
local la=kv(0.05,1-ko.fm+kz,0.95)
local lb=kw.cf+(kw.ky*la)
line(kw.ce,lb,kw.ce+(kw.kx*.60),lb)
lc=5
for bo=1,lc do
local ld=flr(kw.ky/(lc+1))*bo
pset(kw.ce+kw.kx-1,kw.cf+ld,cz.dk)
end
end
function km(gz)
le=lf()
camera(0,0)
local lg=8
for bo=1,#v.fd do
local lh=bo*lg
kb(x(120-lh,120),v.fd[bo])
end
if gz.ez==em.ep then
kd(x(120,120),false)
end
li(le)
end
function lj(rect,ki)
local lk=#ki
local ll=4*lk
local lm=6
local ln=rect.ce+(rect.lo/2)-(ll/2)
local lp=rect.cf+(rect.lq/2)-(lm/2)
return x(ln,lp+1)
end
function jz(w,jy)
local lr=nil
local lt=false
local lu=false
if jy==ed.eg then
lr=134
elseif jy==ed.eh then
lr=133
lu=true
elseif jy==ed.ei then
lr=132
lu=true
elseif jy==ed.ej then
lr=133
lt=true
lu=true
elseif jy==ed.ek then
lr=134
lt=true
elseif jy==ed.el then
lr=133
lt=true
elseif jy==ed.ee then
lr=132
else
lr=133
end
kc(lr,w.ce,w.cf,1,1,lt,lu)
end
function ka(w)
kc(74,w.ce,w.cf,1,1)
end
function kb(w,lv)
kc(lv,w.ce,w.cf,1,1)
end
function kd(w,lw)
local lx=0
if lw then
lx=4
end
kc(72,w.ce,w.cf-lx,1,1)
end
function hh(ki,ly,lz)
local kj,kk=nil,nil
if ly=="warning"then
kj,kk=cz.dl,cz.ma
elseif ly=="item"then
kj,kk=cz.mb,cz.dl
elseif ly=="death"then
kj,kk=cz.mc,cz.md
end
ew={
ki=ki,
kj=kj,
kk=kk,
ge=he(lz),
}
end
function kh(ki,kj,kk)
le=lf()
camera(0,0)
local me={ce=0,cf=98,lo=128,lq=10}
rectfill(me.ce,me.cf,me.ce+me.lo,me.cf+me.lq,kk)
rect(me.ce+1,me.cf+1,me.ce+me.lo-2,me.cf+me.lq-1,kj)
local mf=lj(me,ki)
print(ki,mf.ce,mf.cf,kj)
li(le)
end
function fj(mg)
local mh={}
for bo=1,(mg-1) do
local mi=min((bo+1),es())
add(mh,mj(bo,mi))
end
for map in all(mh) do
local mk=ik(map)
map.hv[mk].gt=ml(true,dp.dr)
map.mm=ik(map)
map.hv[map.mm].gt=ml(false,dp.ds)
end
for map in all(mh) do
local mn=flr(map.mo*map.mo*0.30)
local mp=mq({map},mn)
for mr in all(mp) do
map.hv[mr.ms].gt=ml(false,dp.dt)
end
end
local mt=10
local mu=mq(mh,mt)
for mv in all(mu) do
mv.map.hv[mv.ms].gt=ml(false,dp.dv)
end
local mw={172,173,188,189}
local mx=0
local my=eu()
local mz=mq(mh,my)
for na in all(mz) do
na.map.hv[na.ms].gt=ml(false,dp.dw)
na.map.hv[na.ms].gt.iq=mw[mx+1]
mx=((mx+1)%#mw)
end
for map in all(mh) do
local nb=map.hv[map.mm].w
for gs in all(map.hv) do
if gs.gt.type==dp.dq then
local jh=ji(nb,gs.w)
local nc=atan2(jh.ce,-1*jh.cf)
local nd=nc*360
local jy=nil
if nd<22.5 then
jy=ed.eg
elseif nd<67.5 then
jy=ed.eh
elseif nd<112.5 then
jy=ed.ei
elseif nd<157.5 then
jy=ed.ej
elseif nd<202.5 then
jy=ed.ek
elseif nd<247.5 then
jy=ed.el
elseif nd<292.5 then
jy=ed.ee
elseif nd<337.5 then
jy=ed.ef
else
jy=ed.eg
end
gs.gt.jy=jy
end
end
end
local ne=mj(mg,es())
local nf=flr(#ne.hv/2)+1
ne.hv[nf].gt=ml(true,dp.dx)
ne.hv[nf].gt.ia=true
local ng=ik(ne)
ne.hv[ng].gt=ml(true,dp.dr)
for gs in all(ne.hv) do
if gs.gt.type==dp.dq then
gs.gt=ml(true,dp.dy)
end
end
add(mh,ne)
return mh
end
function mj(io,nh)
local ni={}
ni.io=io
ni.mo=nh
ni.hv={}
local nj=ni.mo*2-1
local nk=nj+4
local ms=1
for nl=1,nk do
local nm=flr((nk+1)/2)
local nn=(nl-nm)*er()/2
local no=nil
if nl<=nm then
no=nl
else
no=2*nm-nl
end
for np=1,no do
local gt=nil
local nq=(np==1) or(np==no)
if nq then
gt=ml(true,dp.du)
else
gt=ml(false,dp.dq)
end
local nr=
-1*((no/2)*eq())
+(eq()/2)
+((np-1)*eq())
local gs={
ms=ms,
gt=gt,
w=x(
ns()/2+nr,
ns()/2+nn),
fa={fb=4}
}
add(ni.hv,gs)
ms+=1
end
end
return ni
end
function ml(gu,nt)
return{gu=gu,type=nt}
end
function ik(map)
return mq({map},1)[1].ms
end
function mq(mh,nu)
local nv=0
local nw={}
for map in all(mh) do
for gs in all(map.hv) do
if gs.gt.type==dp.dq then
add(nw,{map=map,ms=gs.ms})
nv+=1
end
end
end
local nx={}
for bo=1,nu do
local ny=nz(1,nv)
local oa=nw[ny]
nw[ny]=nw[nv]
nw[nv]=nil
add(nx,oa)
end
return nx
end
function jx(gt)
if gt.gu then
local ks=gt.type
if ks==dp.dq then
return 160
elseif ks==dp.dr then
return 108
elseif ks==dp.ds then
return 104
elseif ks==dp.dt then
return 76
elseif ks==dp.du then
return nil
elseif ks==dp.dv then
return 160
elseif ks==dp.dw then
return 160
elseif ks==dp.dx then
return 140
elseif ks==dp.dy then
return 136
else
return nil
end
else
assert(ks!=dp.dx and ks!=dp.dy)
return 96
end
end
function fk(gf,hk)
gr=fi[gf]
local ob=nil
for gs in all(gr.hv) do
if gs.gt.type==hk then
ob=gs
break
end
end
assert(ob!=nil)
v.w=oc(ob.w)
v.ib=ob
v.hz=ob
fe=ja(v)
z(v,ba.od)
gn={}
end
function hm(l)
local oe=0.70710678118
local of=0
local og=0
if l.oh then
if l.oi then
of=-2*oe
og=-1*oe
elseif l.oj then
of=-2*oe
og=oe
else
of=-2
og=0
end
elseif l.ok then
if l.oi then
of=2*oe
og=-1*oe
elseif l.oj then
of=2*oe
og=oe
else
of=2
og=0
end
elseif l.oi then
of=0
og=-1
elseif l.oj then
of=0
og=1
else
return
end
local ol=1.0
of*=ol
og*=ol
local om=oc(v.w)
local on={}
add(on,x(of,og))
if of!=0 then
add(on,x(of,0))
end
if og!=0 then
add(on,x(0,og))
end
for jo in all(on) do
v.w=jl(om,jo)
local hv=gq(gr,v)
local oo=true
for gs in all(hv) do
if gs.gt.type==dp.du then
oo=false
break
end
end
if oo then
return
end
end
v.w=om
end
function hn(l)
local ft=nil
if l.oh then
if l.oi then
ft=ba.iu
elseif l.oj then
ft=ba.iw
else
ft=ba.bb
end
elseif l.ok then
if l.oi then
ft=ba.op
elseif l.oj then
ft=ba.oq
else
ft=ba.os
end
elseif l.oi then
ft=ba.ot
elseif l.oj then
ft=ba.ou
else
if v.fu.hr==ba.bb then
ft=ba.it
elseif v.fu.hr==ba.os then
ft=ba.ov
elseif v.fu.hr==ba.ot then
ft=ba.ow
elseif v.fu.hr==ba.ou then
ft=ba.od
elseif v.fu.hr==ba.iu then
ft=ba.by
elseif v.fu.hr==ba.op then
ft=ba.ox
elseif v.fu.hr==ba.iw then
ft=ba.iv
elseif v.fu.hr==ba.oq then
ft=ba.oy
else
ft=v.fu.hr
end
end
z(v,ft)
end
function dh(oz)
return jl(oz.w,oz.y)
end
function ht(map,pa)
for gs in all(gq(map,pa)) do
if gv(pa,gs) then
return gs.ms
end
end
return nil
end
function gv(pb,pc)
local pd=jg(pb.fa.fb+pc.fa.fb)
local je=jf(pb.w,pc.w)
return je<=pd
end
function gq(map,pa)
hv={}
for gs in all(map.hv) do
if pe(gs,pa) then
add(hv,gs)
end
end
return hv
end
function pe(gs,pa)
local pf={
{lo=12,lq=12},
{lo=18,lq=9},
{lo=26,lq=5},
}
local pg={
w=x(
pa.w.ce-pa.fa.fb,
pa.w.cf-pa.fa.fb),
lo=(pa.fa.fb+pa.fa.fb),
lq=(pa.fa.fb+pa.fa.fb),
}
for ph in all(pf) do
ph.w=x(gs.w.ce-(ph.lo/2),gs.w.cf-(ph.lq/2))
if pi(pg,ph) then
return true
end
end
return false
end
function pi(pj,pk)
local pl=pj.w.ce>=(pk.w.ce+pk.lo)
local pm=pk.w.ce>=(pj.w.ce+pj.lo)
if pl or pm then
return false
end
local pn=pj.w.cf>=(pk.w.cf+pk.lq)
local po=pk.w.cf>=(pj.w.cf+pj.lq)
if pn or po then
return false
end
return true
end
function ke(gs)
local pp=gs.w.ce
local pq=gs.w.cf-1
local pr={
x(pp-eq()/2,pq),
x(pp,pq-er()/2),
x(pp+eq()/2,pq),
x(pp,pq+er()/2),
}
line(pr[1].ce,pr[1].cf,pr[2].ce,pr[2].cf,cz.dk)
line(pr[2].ce,pr[2].cf,pr[3].ce,pr[3].cf,cz.dk)
line(pr[3].ce,pr[3].cf,pr[4].ce,pr[4].cf,cz.dk)
line(pr[4].ce,pr[4].cf,pr[1].ce,pr[1].cf,cz.dk)
end
function ie(w,ig)
local self={
ps="Countdown",
pt=ba.pu,
pv=he(32),
pw={},
px={},
w=oc(w),
ig=ig
}
function py(w)
local oe=0.70710678118
local pz=x(2*oe,-1*oe)
local qa=x(-2*oe,-1*oe)
local qb=x(2*oe,1*oe)
local qc=x(-2*oe,1*oe)
function qd(lr,w)
return{lr=lr,w=w,fa={fb=3}}
end
local qe=10
return{
qd(0,oc(w)),
qd(-8,jl(w,qf(qa,1*qe))),
qd(-16,jl(w,qf(qa,2*qe))),
qd(-24,jl(w,qf(qa,3*qe))),
qd(-8,jl(w,qf(pz,1*qe))),
qd(-16,jl(w,qf(pz,2*qe))),
qd(-24,jl(w,qf(pz,3*qe))),
qd(-8,jl(w,qf(qc,1*qe))),
qd(-16,jl(w,qf(qc,2*qe))),
qd(-24,jl(w,qf(qc,3*qe))),
qd(-8,jl(w,qf(qb,1*qe))),
qd(-16,jl(w,qf(qb,2*qe))),
qd(-24,jl(w,qf(qb,3*qe))),
}
end
local fp=function()
if self.ps=="Countdown"then
z(self,self.pt)
if self.fu.fx>0 then
self.ps="Explode"
self.pw=py(self.w)
end
elseif self.ps=="Explode"then
self.pv.fp()
if self.pv.gc() then
self.ps="Done"
self.pw={}
self.px={}
end
for bq in all(self.pw) do
bq.lr+=1
if bq.lr==1 then
add(self.px,bq)
self.ig()
elseif bq.lr==13 then
del(self.px,bq)
end
end
else
end
end
local gc=function()
return self.ps=="Done"
end
local kg=function()
if self.ps=="Countdown"then
dg(self,x(self.w.ce-4,self.w.cf-4))
elseif self.ps=="Explode"then
for bq in all(self.pw) do
local qg=2
local dd=(qg-1)*((6-abs(bq.lr-6))/6)+1
if bq.lr<0 then
elseif bq.lr<4 then
ch(90,bq.w.ce,bq.w.cf,1,1,dd)
elseif bq.lr<8 then
ch(91,bq.w.ce,bq.w.cf,1,1,dd)
elseif bq.lr<12 then
ch(90,bq.w.ce,bq.w.cf,1,1,dd)
else
end
end
else
end
end
local go=function()
return self.px
end
return{
fp=fp,
kg=kg,
gc=gc,
go=go
}
end
function qh()
return"you were unable to make\nyour way to the bottom\nof the grave in time.\n\nyour family's most\ncherished heirloom is\nlost. gone forever.\n\nthis is unacceptable.\nyou'll have to try again.\n\nx/c - to reset"
end
function qi(qj,qk)
local ki="you made it back with the book. a brown book stitched together with strong thread and thick brown pages. a family heirloom."
if qj==0 then
ki=ki.." opening the book you realize several pages are missing. maybe they're back down in the grave. at least you saved the book. in another life, maybe you could find those pages.\n\nx/c - to reset"
elseif qj<qk then
local ql=nil
if qj==1 then
ql="page"
else
ql="pages"
end
local qm=nil
if qj==(qk-1) then
qm="is still 1 page missing. maybe the last page is"
else
qm="are still "..(qk-qj).." pages missing. maybe the rest are"
end
ki=ki.." setting the "..qj.." recovered "..ql.." in the book you realize there "..qm.." back down in the grave. it's not whole, but there's comfort in what you have. in another life, maybe you could recover the rest.\n\nx/c - to reset"
else
ki=ki.." setting all "..qk.." pages you found below in the book, you realize the book is complete.\nit reveals its story to you.\n\nthe first page reads:\n\"collard greens. wash greens 7 times. tear 'em up. throw 'em in a large pot. cover greens with water.  add onion, garlic, some peppa, spoonful of vinegar, and one ham hock. cover the pot and bring to a boil.\n\nthe book's previous owner was a driven, young man who desperately wanted to raise his daughter well. a self-taught cook, he learned that the collard recipe was full of love, flavor, and the secret ingredient, perseverance. a giant sunday pot of collards became tradition, providing them with greens for the whole week.\"\nx/c - to reset"
end
return bj(ki)
end
function gx(qn)
ey={
jm="scroll_timer",
jn=0,
}
if qn then
ey.jt=qi(#v.fd,eu())
else
ey.jt=qh()
end
ff.qo(true)
g(a.d)
music(-1,1000)
end
cw={
hx=1,
im=2,
ir=3,
ih=21,
cx=5,
ip=6,
hi=7,
}
function qp(qq,qr,qs,flip)
return{
qq=qq,
qt=count(qq),
qr=qr,
qs=qs,
flip=flip,
}
end
function fy(oz)
oz.fu.qu=0
oz.fu.fv=0
oz.fu.fx=0
end
function z(oz,ft)
oz.fu=oz.fu or{qu=0,fv=0,qv=0,fx=0}
local fu=oz.fu
fu.qu+=1
local qw=fu.qu%(30/ft.qr)==0
if qw then
fu.fv+=1
if fu.fv>=ft.qt then
fu.fv=0
fu.fx+=1
end
elseif fu.fv>=ft.qt then
fu.fv=0
end
local lr=ft.qq[fu.fv+1]
fu.qv=lr
fu.flip=ft.flip
fu.qs=ft.qs
fu.hr=ft
end
function dg(oz,qx)
local fu=oz.fu
spr(fu.qv,qx.ce,qx.cf,fu.qs,fu.qs,fu.flip)
end
function f()
ba={
od=qp({34},10,2,false),
ou=qp({32,34,36},10,2,false),
ow=qp({40},10,2,false),
ot=qp({38,40,42},10,2,false),
ov=qp({66},10,2,false),
os=qp({64,66,68},10,2,false),
it=qp({66},10,2,true),
bb=qp({64,66,68},10,2,true),
ox=qp({8},10,2,false),
op=qp({6,8,10},10,2,false),
oy=qp({2},10,2,false),
oq=qp({0,2,4},10,2,false),
by=qp({8},10,2,true),
iu=qp({6,8,10},10,2,true),
iv=qp({2},10,2,true),
iw=qp({0,2,4},10,2,true),
ix=qp({12,12,14},5,2,false),
bz=qp({12,12,14},5,2,true),
iy=qp({70,70,224},5,2,true),
iz=qp({70,70,224},5,2,false),
hc=qp({46},1,2,false),
pu=qp({74,74,74,74,74,74,74,75,74,74,75,74,74,75,74},15,1,false),
}
end
function he(qy)
local self={
qq=0,
qy=qy,
}
local fp=function()
if self.qq<self.qy then
self.qq+=1
end
end
local gc=function()
return self.qq>=self.qy
end
local qz=function()
return self.qq/self.qy
end
return{
qz=qz,
fp=fp,
gc=gc
}
end
function fg(ra,rb)
local self={
rc=false,
rd=0,
re=25,
rf=nil,
rg=false,
ra=ra,
rb=rb,
rh=42,
ri=10,
}
local rj=function(rk)
return rk/self.rb
end
local rl=function(rk)
if rk==0 or rk==self.rb then
return false
end
local rm=flr(self.rb/24)
local rn=10
return(rk%rm)<rn
end
local qo=function(rc)
self.rc=rc
end
local ro=function()
if not self.rc then
return false
end
return self.rd>=self.re
end
local rp=function(rq)
local rr=flr(rq/60)
local rs=rq%60
local rt=flr(rs)
local ru=(rs&0x0000.ffff)*60
local rv=flr(ru)
return{rw=rr,rx=rt,ry=rv}
end
local rz=function()
self.sa=true
end
local sb=function(rk)
if self.rc then
self.rd+=1
if self.rd>(self.re*1.5) then
self.rd=0
end
end
local sc=rl(rk)
if sc and(not self.rg) then
self.ra()
end
self.rg=sc
end
local sd=function(rk)
if ro() then
return
end
local se=cz.dk
local sf=self.rh
local sg=self.ri
if self.rg then
se=cz.sh
sf+=nz(-1,1)
sg+=nz(-1,1)
end
local si=rj(rk)
local sj=(24*60)
local sk=(1-si)*sj
local time=rp(sk)
local sl=sm(time.rw,2).."H:"..sm(time.rx,2).."M:"..sm(time.ry,2).."S"
print(sl,sf+1,sg+1,cz.sn)
print(sl,sf,sg,se)
end
local so=function(ce,cf)
self.rh+=ce
self.ri+=cf
end
return{
qo=qo,
fp=sb,
kg=sd,
jo=so,
}
end
cz={
da=0,
md=1,
dc=2,
mb=3,
di=4,
sn=5,
sp=6,
dk=7,
mc=8,
sq=9,
sh=10,
sr=11,
ss=12,
ma=13,
st=14,
dl=15,
}
function ns()
return 128
end
function nz(su,sv)
return flr(rnd(sv-su))+su
end
function kv(su,sw,sv)
return mid(su,sw,sv)
end
function e()
poke(0x5f5c,255)
end
function m()
return{
oh=btn(0),
sx=btnp(0),
ok=btn(1),
sy=btnp(1),
oi=btn(2),
sz=btnp(2),
oj=btn(3),
ta=btnp(3),
hp=btn(4),
cu=btnp(4),
id=btn(5),
ct=btnp(5),
tb=btnp()!=0,
}
end
function sm(tc,lo)
local td=tostr(tc)
repeat
tc=flr(tc/10)
lo-=1
until(lo<=0) or(tc<=0)
while(lo>0) do
td="0"..td
lo-=1
end
return td
end
function jg(ce)
return ce*ce
end
function jf(te,tf)
return jg(te.ce-tf.ce)+jg(te.cf-tf.cf)
end
function lf()
return{ce=peek2(0x5f28),cf=peek2(0x5f2a)}
end
function li(tg)
camera(tg.ce,tg.cf)
end
function x(ce,cf)
return{ce=ce,cf=cf}
end
function oc(cn)
return x(cn.ce,cn.cf)
end
function jl(th,ti)
return x(th.ce+ti.ce,th.cf+ti.cf)
end
function ji(th,ti)
return x(th.ce-ti.ce,th.cf-ti.cf)
end
function qf(cn,td)
return x(cn.ce*td,cn.cf*td)
end
function kc(lr,ce,cf,tj,tk,lt,lu)
lt=lt or false
lu=lu or false
spr(lr,ce-(tj*8/2),cf-(tk*8/2),tj,tk,lt,lu)
end
function ch(lr,ce,cf,tj,tk,dd,lt,lu)
lt=lt or false
lu=lu or false
local tl=(lr%16)*8
local tm=flr(lr/16)*8
local tn=tj*8
local to=tk*8
local tp=dd*tn
local tq=dd*to
local rh=(ce-tp/2)
local ri=(cf-tq/2)
sspr(tl,tm,tn,to,rh,ri,tp,tq,lt,lu)
end
function dn(ki,t,ce,cf,tg,tr)
tg=tg or cz.dk
local ts=1
local tt=flr((#ki)*t)
local tu=0
for bo=1,tt do
local tv=tt-(bo-1)
local tw=sub(ki,tv,tv)
if tw=="\n"then
tu+=1
if tu>=tr then
ts=tv+1
break
end
end
end
print(sub(ki,ts,tt),ce,cf,tg)
end
function bj(ki)
local bj=""
local tx=0
while tx<#ki do
local tt=min(tx+1+25,#ki)
local ty=nil
if tt==#ki then
ty=sub(ki,tx+1)
else
local tz=nil
for bo=(tx+1),tt do
if sub(ki,bo,bo)=="\n"then
tz=bo
end
end
if tz!=nil then
ty=sub(ki,tx+1,tz-1).." "
else
while sub(ki,tt,tt)!=" "do
tt-=1
end
ty=sub(ki,tx+1,tt)
end
end
if bj==""then
bj=ty
else
bj=bj.."\n"..ty
end
tx+=#ty
end
return bj
end
function bh(ua,ub)
local td=""
for bo=1,(#ua-1) do
t=ua[bo]
td=td..t
for uc=1,ub do td=td.." "end
td=td.."\n\n"
end
return td..ua[#ua]
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

