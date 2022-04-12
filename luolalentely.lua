-- title:  LUALA
-- author: Team Mystery Dungeon
-- desc:   local multiplayer cave flier
-- script: lua

cos=math.cos
sin=math.sin
pi=math.pi
fmt=string.format
ins=table.insert
rem=table.remove
t=0
x=96+10
y=24+48
a=pi/2
grav=0.2

shots={}
static={}
missiles={}
lazers={}

scrap={0,0,0,0}

fadeouts={}

function OVR()
		if TIC==update then
		for j=1,#ships do
		clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
		UIdraw(j)
		end
		end
end

function update()
	--cls(0)
		for j=1,#ships do
		clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
		clear_ship_trails(j)
		end
		for j=1,#ships do
		clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
		shipprocess(j)
		--renderwindow(j)
		cameraprocess(j)
		end

		clip()
		environprocess()		
		
		for j=1,#ships do
		clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
		shipdraw(j)
		end
		
		handle_kills()
		
	--spr(1+t%60//30*2,x,y,14,3,0,0,2,2)
	--print("HELLO WORLD!",84,84)
		--cam.sx=x-240/2; cam.sy=y-136/2
		--memcpy(3*120+cams[2].ax/2-1,cams[2].ax/2,cams[2].aw/2)
	
		t=t+1
end

function cameraprocess(j)
		old_cams[j]={sx=cams[j].sx, sy=cams[j].sy, x=cams[j].x, y=cams[j].y}
		camerafollow(j,'x')
		if cams[j].x~=old_cams[j].x then
				nudgewindow(j,old_cams[j].x-cams[j].x,0)
		end
		camerafollow(j,'y')
		if cams[j].y~=old_cams[j].y then
				nudgewindow(j,0,old_cams[j].y-cams[j].y)
		end
end

function nudgewindow(j,dx,dy)
		if not (dx==-2 or dx==2 or dx==0) or not (dy==1 or dy==-1 or dy==0 or dy==-2) then
		trace(fmt('%d,%d',dx,dy))
		end
		if dx==-2 then
				for i=0,cams[j].ah-1 do
						memcpy((cams[j].ay+i)*120+cams[j].ax/2,(cams[j].ay+i)*120+cams[j].ax/2+1,cams[j].aw/2-1)
				end
				for x=cams[j].aw-2,cams[j].aw-1 do
				for y=0,cams[j].ah-1 do
						local p= pixels[posstr(cams[j].x+x,cams[j].y+y)]
						if p then pix(cams[j].ax+x,cams[j].ay+y,p)
						else pix(cams[j].ax+x,cams[j].ay+y,0) end
				end
				end
		end
		if dx==2 then
				for i=0,cams[j].ah-1 do
						memcpy((cams[j].ay+i)*120+cams[j].ax/2+1,(cams[j].ay+i)*120+cams[j].ax/2,cams[j].aw/2-1)
				end
				for x=0,1 do
				for y=0,cams[j].ah-1 do
						local p= pixels[posstr(cams[j].x+x,cams[j].y+y)]
						if p then pix(cams[j].ax+x,cams[j].ay+y,p)
						else pix(cams[j].ax+x,cams[j].ay+y,0) end
				end
				end
		end
		if dy==-1 or dy==-2 then
				for i=-dy,cams[j].ah-1 do
						memcpy((cams[j].ay+i+dy)*120+cams[j].ax/2,(cams[j].ay+i)*120+cams[j].ax/2,cams[j].aw/2)
				end
				for x=0,cams[j].aw-1 do
				for y=cams[j].ah+dy,cams[j].ah-1 do
						local p= pixels[posstr(cams[j].x+x,cams[j].y+y)]
						if p then pix(cams[j].ax+x,cams[j].ay+y,p)
						else pix(cams[j].ax+x,cams[j].ay+y,0) end
				end
				end
		end
		if dy==1 then
				for i=cams[j].ah-2,0,-1 do
						memcpy((cams[j].ay+i+1)*120+cams[j].ax/2,(cams[j].ay+i)*120+cams[j].ax/2,cams[j].aw/2)
				end
				for x=0,cams[j].aw-1 do
				for y=0,0 do
						local p= pixels[posstr(cams[j].x+x,cams[j].y+y)]
						if p then pix(cams[j].ax+x,cams[j].ay+y,p)
						else pix(cams[j].ax+x,cams[j].ay+y,0) end
				end
				end
		end
end

function cam_init(j)
		if j==1 and not cams then 
				if #ships==1 then
						cams={{sx=0,sy=0,ax=0,ay=0,aw=240,ah=136}}
				elseif #ships==2 then
						--for i=0,3 do line(240/2-2+i,0,240/2-2+i,136,8) end
						cams={{sx=0,sy=0,ax=0,ay=0,aw=240/2-2,ah=136},
					 	     {sx=240,sy=136,ax=240/2+2,ay=0,aw=240/2-2,ah=136}}
				elseif #ships==3 then
						--for i=0,3 do line(240/2-2+i,0,240/2-2+i,136/2-2,8) end
						--for i=0,3 do line(0,136/2-2+i,240,136/2-2+i,8) end
						cams={{sx=0,sy=0,ax=0,ay=0,aw=240/2-2,ah=136/2-2},
					 	     {sx=240,sy=136,ax=240/2+2,ay=0,aw=240/2-2,ah=136/2-2},
												{sx=240,sy=0,ax=240/2-(240/2)/2+2,ay=136/2+2,aw=240/2-2,ah=136/2-2}}
				elseif #ships==4 then
						cams={{sx=0,sy=0,ax=0,ay=0,aw=240/2-2,ah=136/2-2},
            {sx=240,sy=136,ax=240/2+2,ay=0,aw=240/2-2,ah=136/2-2},
            {sx=240,sy=0,ax=0,ay=136/2+2,aw=240/2-2,ah=136/2-2},
            {sx=0,sy=136,ax=240/2+2,ay=136/2+2,aw=240/2-2,ah=136/2-2}}
				end
				old_cams={}
		end
		
		
		renderwindow(j)		

		old_cams[j]={sx=cams[j].sx,sy=cams[j].sy,x=cams[j].x,y=cams[j].y}
end

function renderwindow(j)
		clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)

		cls(0)
		camerafollow(j)
		for x=0,cams[j].aw-1 do for y=0,cams[j].ah-1 do
				local p=pixels[posstr(cams[j].x+x,cams[j].y+y)]
				if p then
						pix(cams[j].ax+x,cams[j].ay+y,p)
				end
		end end
end

function camerafollow(j,dir)
		if (not dir) or dir=='x' then
		cams[j].x=ships[j].x-cams[j].aw/2
		cams[j].x=cams[j].x-cams[j].x%2
		cams[j].x=math.floor(cams[j].x)
		if cams[j].x<cams[j].sx then
				cams[j].x=cams[j].sx
		end
		if cams[j].x>=cams[j].sx+240-cams[j].aw then
				cams[j].x=cams[j].sx+240-cams[j].aw
		end
		end
		if (not dir) or dir=='y' then
		cams[j].y=ships[j].y-cams[j].ah/2
		cams[j].y=math.floor(cams[j].y)
		--cams[j].y=cams[j].y-cams[j].y%2
		if cams[j].y<cams[j].sy then
				cams[j].y=cams[j].sy
		end
		if cams[j].y>=cams[j].sy+136-cams[j].ah then
				cams[j].y=cams[j].sy+136-cams[j].ah
		end
		end
end

function handle_kills()
		for j=#ships,1,-1 do
				local s=ships[j]
				if s.gone then 
				ins(fadeouts,cams[j])
				fadeouts[#fadeouts].prog=0
				fadeouts[#fadeouts].ship=s
				
				rem(ships,j); rem(cams,j); rem(old_cams,j) 
				rem(inventory,j)
				
				for j2,s2 in ipairs(ships) do
				local cam=cams[j2]
				clip(cam.ax,cam.ay,cam.aw,cam.ah)
				line(cam.ax-cam.x+s.x-cos(s.a)*8,cam.ay-cam.y+s.y-sin(s.a)*8,cam.ax-cam.x+s.x-cos(s.a-2*pi/3-0.3)*11,cam.ay-cam.y+s.y-sin(s.a-2*pi/3-0.3)*11,0)
				line(cam.ax-cam.x+s.x-cos(s.a-2*pi/3-0.3)*11,cam.ay-cam.y+s.y-sin(s.a-2*pi/3-0.3)*11,cam.ax-cam.x+s.x+cos(s.a)*4,cam.ay-cam.y+s.y+4*sin(s.a),0)
				line(cam.ax-cam.x+s.x+cos(s.a)*4,cam.ay-cam.y+s.y+4*sin(s.a),cam.ax-cam.x+s.x-cos(s.a+2*pi/3+0.3)*11,cam.ay-cam.y+s.y-sin(s.a+2*pi/3+0.3)*11,0)
				line(cam.ax-cam.x+s.x-cos(s.a+2*pi/3+0.3)*11,cam.ay-cam.y+s.y-sin(s.a+2*pi/3+0.3)*11,cam.ax-cam.x+s.x-cos(s.a)*8,cam.ay-cam.y+s.y-sin(s.a)*8,0)
				for bx=math.floor(s.x-12),math.floor(s.x+12) do for by=math.floor(s.y-12),math.floor(s.y+12) do
						local p=pixels[posstr(bx,by)]
						if p then
								pix(cam.ax+bx-cam.x,cam.ay+by-cam.y,p)
						end--else pix(cam.ax+bx-cam.x,cam.ay+by-cam.y,0) end
				end end
				end

				end
		end
		
		redfade()
end

function redfade()
		for i=#fadeouts,1,-1 do
				local f=fadeouts[i]
				clip(f.ax,f.ay,f.aw,f.ah)
				for x=0,f.aw-1 do for y=math.max(f.ah-f.prog-20,0),f.ah-f.prog do
						if pix(f.ax+x,f.ay+y)==0 then
								pix(f.ax+x,f.ay+y,2)
						end
				end end
				
				local points={{x=f.ship.x-cos(f.ship.a)*8,y=f.ship.y-sin(f.ship.a)*8},
	         								{x=f.ship.x-cos(f.ship.a-2*pi/3-0.3)*11,y=f.ship.y-sin(f.ship.a-2*pi/3-0.3)*11},
																		{x=f.ship.x+cos(f.ship.a)*4,y=f.ship.y+4*sin(f.ship.a)},
																		{x=f.ship.x-cos(f.ship.a+2*pi/3+0.3)*11,y=f.ship.y-sin(f.ship.a+2*pi/3+0.3)*11}}
				
				local silhouette=false
				for k,pt in ipairs(points) do
				if f.ay+f.ah-f.prog<f.ay+pt.y-f.y then
						silhouette=true
						break
				end
				end
				if silhouette then
						for k,pt in ipairs(points) do
								if k<#points then line(f.ax+pt.x-f.x,f.ay+pt.y-f.y,f.ax+points[k+1].x-f.x,f.ay+points[k+1].y-f.y,0)
								else line(f.ax+pt.x-f.x,f.ay+pt.y-f.y,f.ax+points[1].x-f.x,f.ay+points[1].y-f.y,0) end
						end
				end
				
				if f.prog>f.ah then
						rem(fadeouts,i)
				end
				f.prog=f.prog+20
		end
end

ships={}

function clear_ship_trails(j)
		local old_cam=old_cams[j]
		local cam=cams[j]
		for k,s in ipairs(ships) do

		if not s.trans then
		line(cam.ax-cam.x+s.x-cos(s.a)*8,cam.ay-cam.y+s.y-sin(s.a)*8,cam.ax-cam.x+s.x-cos(s.a-2*pi/3-0.3)*11,cam.ay-cam.y+s.y-sin(s.a-2*pi/3-0.3)*11,0)
		line(cam.ax-cam.x+s.x-cos(s.a-2*pi/3-0.3)*11,cam.ay-cam.y+s.y-sin(s.a-2*pi/3-0.3)*11,cam.ax-cam.x+s.x+cos(s.a)*4,cam.ay-cam.y+s.y+4*sin(s.a),0)
		line(cam.ax-cam.x+s.x+cos(s.a)*4,cam.ay-cam.y+s.y+4*sin(s.a),cam.ax-cam.x+s.x-cos(s.a+2*pi/3+0.3)*11,cam.ay-cam.y+s.y-sin(s.a+2*pi/3+0.3)*11,0)
		line(cam.ax-cam.x+s.x-cos(s.a+2*pi/3+0.3)*11,cam.ay-cam.y+s.y-sin(s.a+2*pi/3+0.3)*11,cam.ax-cam.x+s.x-cos(s.a)*8,cam.ay-cam.y+s.y-sin(s.a)*8,0)
		else s.trans=nil end
		for bx=math.floor(s.x-12),math.floor(s.x+12) do for by=math.floor(s.y-12),math.floor(s.y+12) do
				local p=pixels[posstr(bx,by)]
				if p then
						pix(cam.ax+bx-cam.x,cam.ay+by-cam.y,p)
				end--else pix(cam.ax+bx-cam.x,cam.ay+by-cam.y,0) end
		end end

		local p=pixels[posstr(s.x,s.y)]
		if p then pix(cam.ax+s.x-cam.x,cam.ay+s.y-cam.y,p)
		else pix(cam.ax+s.x-cam.x,cam.ay+s.y-cam.y,0) end

		--[[local rw=s.hp/30*(cam.aw-8)
		for x=cam.ax+4,cam.ax+4+rw do for y=cam.ay+cam.ah-1-4,cam.ay+cam.ah-1-4+2 do
				local p=pixels[posstr(x-cam.ax+cam.x,y-cam.ay+cam.y)]
				if p then
						pix(x,y,p)
				else pix(x,y,0) end
		end end
		]]
		end
		
		if alerts[j] then
				--[[for x=cam.ax,cam.ax+cam.aw-1 do for y=cam.ay,cam.ay+6-1 do
						local p=pixels[posstr(x-cam.ax+cam.x,y-cam.ay+cam.y)]
						if p then
								pix(x,y,p)
						else pix(x,y,0) end
				end end]]
		end

end

function shipprocess(j)
		local s=ships[j]
		local cam=cams[j]
		local old_cam=old_cams[j]

		--s.oldx=s.x; s.oldy=s.y		
		s.dx=0; s.dy=0; s.da=0
		if btn((s.id-1)*8) then s.x=s.x-cos(s.a); s.y=s.y-sin(s.a); s.dx=-cos(s.a); s.dy=-sin(s.a); s.moved=true end
		if btn((s.id-1)*8+1) then s.x=s.x+cos(s.a); s.y=s.y+sin(s.a); s.dx=cos(s.a); s.dy=sin(s.a) end
		if btn((s.id-1)*8+2) and (not s.onbase or btn((s.id-1)*8) or btn((s.id-1)*8+1)) then s.a=s.a-0.1; s.da=-0.1 end
		if btn((s.id-1)*8+3) and (not s.onbase or btn((s.id-1)*8) or btn((s.id-1)*8+1)) then s.a=s.a+0.1; s.da=0.1 end
		-- shot1 and shot2
		for i=1,2 do
		local id
		if s[fmt('shot%d',i)] then id= inventory[j][s[fmt('shot%d',i)].invi].id end
		if ((btnp((s.id-1)*8+4+i-1) and id~=19) or (id==19 and t%6==0)) and not s.onbase then 
				if s[fmt('shot%d',i)] then 
						if s[fmt('shot%d',i)].nrj>0 then
						if id==32 then ins(shots,{x=s.x-3,y=s.y-3,id=id,dx=cos(s.a+pi)*3,dy=sin(s.a+pi)*3,owner=s}) end
						if id==50 then ins(shots,{x=s.x-3,y=s.y-3,id=id,dx=cos(s.a+pi)*3,dy=sin(s.a+pi)*3,owner=s}) end
						if id==49 then ins(static,{x=s.x-3,y=s.y-3,id=id,dx=0,dy=0,owner=s,iframes=90}) end
						if id==34 then ins(missiles,{x=s.x-4,y=s.y-4,a=s.a+pi,id=id,dx=cos(s.a+pi)*5,dy=sin(s.a+pi)*5,owner=s}) end
						if id==17 then ins(static,{x=s.x-4,y=s.y-4,id=id,owner=s}) end
						if id==19 then 
								local distances={}
								for j2,s2 in ipairs(ships) do
										if s2~=s then
												ins(distances,{s=s2,d=math.sqrt((s.x-s2.x)^2+(s.y-s2.y)^2)})
										end
								end
								table.sort(distances,function(a,b) return a.d<b.d end)
								if distances[1] and distances[1].d<=140 then
										local s2=distances[1].s
										local a=math.atan2(s2.y-s.y,s2.x-s.x)
										ins(lazers,{x=s.x-4,y=s.y-4,a=a,dx=cos(a)*3,dy=sin(a)*3,owner=s})
								end
						end 
						s[fmt('shot%d',i)].nrj=s[fmt('shot%d',i)].nrj-1
						if id==19 then s[fmt('shot%d',i)].nrj=max_nrj(j,i) end
						if s[fmt('shot%d',i)].nrj==0 then alert(j,fmt('Shot%d out of ammo. Go to base.',i)) end
						else alert(j,fmt('Shot%d out of ammo. Go to base.',i)) end
				else alert(j,fmt('Shot%d not set. Go to base.',i)) end
		end
		end
	
		s.y=s.y+grav
		s.dy=s.dy+grav

		local hit=pixels[posstr(s.x,s.y)]--pix(cam.ax+s.x-cam.x,cam.ay+s.y-cam.y)
		-- walls
		if hit==13 or hit==14 or hit==15 or oob(s.x,s.y) then
				s.y=s.y-s.dy; s.x=s.x-s.dx; --a=a-da
		end
		
		hit=pix(cam.ax+s.x-cam.x,cam.ay+s.y-cam.y)
		if hit==2 or hit==3 or hit==4 then
				transition(j,s,-cam.sx+s.x,-cam.sy+s.y)
		end
		forcetransition(j,s,-cam.sx+s.x,-cam.sy+s.y)
		
		local points={{s.x-cos(s.a)*8,s.y-sin(s.a)*8},
		              {s.x-cos(s.a-2*pi/3-0.3)*11,s.y-sin(s.a-2*pi/3-0.3)*11},
																--{-cam.sx+x+cos(a)*4,-cam.sy+y+4*sin(a)},
																{s.x-cos(s.a+2*pi/3+0.3)*11,s.y-sin(s.a+2*pi/3+0.3)*11}}	
		for i,v in ipairs(points) do
		-- base
		local hit=pix(cam.ax+v[1]-cam.x,cam.ay+v[2]-cam.y)
		if hit==5 or hit==6 or hit==7 or hit==12 then
				if not is_sprite(v[1],v[2]) then
				s.y=s.y-s.dy; s.x=s.x-s.dx; s.a=s.a-s.da
				if not s.onbase then
				s.onbase=t
				s.oldx=s.x; s.oldy=s.y; s.olda=s.a
				end
				break
				end
		end
	
		end
		
		if s.onbase then 
				if (t-s.onbase)%4==0 then
				for i=1,2 do
				if s[fmt('shot%d',i)] then
				s[fmt('shot%d',i)].nrj=s[fmt('shot%d',i)].nrj+1
				if s[fmt('shot%d',i)].nrj>max_nrj(j,i) then
				s[fmt('shot%d',i)].nrj=max_nrj(j,i)
				end	end
				end
				end
				if (t-s.onbase)%12==0 then
				s.hp=s.hp+1
				if s.hp>30 then s.hp=30 end
				end
				if math.floor(s.oldy)~=math.floor(s.y) or math.floor(s.oldx)~=math.floor(s.x) or s.a~=s.olda then
						s.onbase=nil
				end
		end

		--old_cams[j]={sx=cam.sx, sy=cam.sy, x=cam.x, y=cam.y}
end

function max_nrj(j,shoti)
		local s=ships[j]
		local i=s[fmt('shot%d',shoti)].invi
		local id=inventory[j][i].id
		return idtags[id].nrj
end

function is_sprite(x,y)
		for i,ms in ipairs(missiles) do
				if ms.oldpos and AABB(x,y,1,1,ms.x,ms.y,8,8) then
						return true
				end
		end
		for i,p in ipairs(powerups) do
				if p.oldpos and math.sqrt((p.oldpos.x-x)^2+(p.oldpos.y-y)^2)<=10 then
						return true
				end
		end
		for i,sh in ipairs(shots) do
				if sh.oldpos and AABB(x,y,1,1,sh.oldpos.x,sh.oldpos.y,8,8) then return true end
		end
		return false
end

-- basic AABB collision.
    function AABB(x1,y1,w1,h1, x2,y2,w2,h2)
        return (x1 < x2 + w2 and
                x1 + w1 > x2 and
                y1 < y2 + h2 and
                y1 + h1 > y2)
    end

function environprocess()
		while #powerups<5 do
				create_powerup(0,240*2-1,0,136*2-1)
		end
		
		-- flashing transitions
		trc=2+(t*0.2)%4
		if trc>=5 then trc=3 end
		for j,s in ipairs(ships) do
		clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)

		if cams[j].x==cams[j].sx then
				for x=cams[j].x,cams[j].x+1 do for y=cams[j].y,cams[j].y+cams[j].ah-1 do
					if pixels[posstr(x,y)]==2 then
							pix(cams[j].ax+x-cams[j].x,cams[j].ay+y-cams[j].y,trc)
					end
				end end
		end
		if cams[j].y<=cams[j].sy+1 then
				for x=cams[j].x,cams[j].x+cams[j].aw-1 do for y=cams[j].y,cams[j].y+1 do
					if pixels[posstr(x,y)]==2 then
							pix(cams[j].ax+x-cams[j].x,cams[j].ay+y-cams[j].y,trc)		
					end
				end end
		end
		if cams[j].x>=cams[j].sx+240-2-cams[j].aw then
				for x=cams[j].sx+240-2,cams[j].sx+240-1 do for y=cams[j].y,cams[j].y+cams[j].ah-1 do
					if pixels[posstr(x,y)]==2 then
							pix(cams[j].ax+x-cams[j].x,cams[j].ay+y-cams[j].y,trc)		
					end
				end end
		end
		if cams[j].y>=cams[j].sy+136-2-cams[j].ah then
				for x=cams[j].x,cams[j].x+cams[j].aw-1 do for y=cams[j].sy+136-2,cams[j].sy+136-1 do
					if pixels[posstr(x,y)]==2 then
							pix(cams[j].ax+x-cams[j].x,cams[j].ay+y-cams[j].y,trc)		
					end
				end end
		end
		--[[for x=0,240*2-1 do for y=136-2,136-1+2 do
			if pixels[posstr(x,y)]==2 then
				pix(cams[j].ax+x-cams[j].x,cams[j].ay+y-cams[j].y,2+(t*0.2)%3)
			end
		end end
		for x=240-2,240-1+2 do for y=0,136*2-1 do
			if pixels[posstr(x,y)]==2 then
				pix(cams[j].ax+x-cams[j].x,cams[j].ay+y-cams[j].y,2+(t*0.2)%3)
			end
		end end]]
		end
		clip()

		for i=#static,1,-1 do
				local st=static[i]
				if st.oldpos then
						for lx=0,8 do for ly=0,8 do
								--if sprpix(st.id,lx,ly)~=0 then
										local px,py=st.oldpos.x,st.oldpos.y
										local p=pixels[posstr(px+lx,py+ly)]
				
										for i,e in ipairs(explosions) do
												if math.sqrt((e.x-(px+lx))^2+(e.y-(py+ly))^2)<=e.r+1+3 then
														-- preserve explosions
														-- so we can have chain reactions
														p= 4-(60-(e.t+1))*0.2
														--trace(fmt('explosion preserved (%d)',math.floor(p)))
														break
												end
										end
				
										for j,s in ipairs(ships) do
										clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
										if not p then
												pix(cams[j].ax-cams[j].x+px+lx,cams[j].ay-cams[j].y+py+ly,0)
												--trace('black pixel')
										else 
										if p==2 then p=trc end
										pix(cams[j].ax-cams[j].x+px+lx,cams[j].ay-cams[j].y+py+ly,p) end
										--trace('colored pixel')
										end
										clip()
								--end
						end end
				end
		end
		-- special logic for drones
		for i,st in ipairs(static) do
				if st.id==17 then
						if t%6==0 then
								local distances={}
								for j,s in ipairs(ships) do
										if st.owner~=s then
												ins(distances,{s=s,d=math.sqrt((st.x-s.x)^2+(st.y-s.y)^2)})
										end
								end
								table.sort(distances,function(a,b) return a.d<b.d end)
								if distances[1] and distances[1].d<=140 then
										local s=distances[1].s
										local a=math.atan2(s.y-st.y,s.x-st.x)
										ins(lazers,{x=st.x,y=st.y,a=a,dx=cos(a)*3,dy=sin(a)*3,owner=st})
								end
						end
				end
		end
		
		for i,p in ipairs(powerups) do
				if p.oldpos then
				for j,s in ipairs(ships) do
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				for x=0,16 do for y=0,16 do
						local pox,poy=p.oldpos.x,p.oldpos.y
						if pox<0 then pox=math.floor(pox+0.999) end
						if poy<0 then poy=math.floor(poy+0.999) end

				  local px= pixels[posstr(pox-8+x,poy-8+y)]
						if px==2 then px=trc end
						if px then pix(cams[j].ax+pox-cams[j].x-8+x,cams[j].ay+poy-cams[j].y-8+y,px)
						else pix(cams[j].ax+pox-cams[j].x-8+x,cams[j].ay+poy-cams[j].y-8+y,0) end				
				end end
				end
				end
		end
		for i=#powerups,1,-1 do
				local p=powerups[i]
				for j,s in ipairs(ships) do
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				spr(36,cams[j].ax+p.x-8-cams[j].x,cams[j].ay+p.y-8-cams[j].y+sin(t*0.08)*2.5,0,1,0,0,2,2)
				spr(p.id,cams[j].ax+p.x-4-cams[j].x,cams[j].ay+p.y-4-cams[j].y+sin(t*0.08)*2.5,0)
				end
				p.oldpos={x=p.x,y=p.y+sin(t*0.08)*2.5}
				for j,s in ipairs(ships) do
				local inv_full=true
				for i=1,9 do
						if not inventory[j][i] then inv_full=false; break end
				end
				if not inv_full then 

				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				local points={{x=s.x-cos(s.a)*8,y=s.y-sin(s.a)*8},
	         								{x=s.x-cos(s.a-2*pi/3-0.3)*11,y=s.y-sin(s.a-2*pi/3-0.3)*11},
																		{x=s.x+cos(s.a)*4,y=s.y+4*sin(s.a)},
																		{x=s.x-cos(s.a+2*pi/3+0.3)*11,y=s.y-sin(s.a+2*pi/3+0.3)*11}}
				for k,pt in ipairs(points) do
				if math.sqrt((pt.x-p.oldpos.x)^2+(pt.y-p.oldpos.y)^2)<=8 then
				for j2,s2 in ipairs(ships) do
				clip(cams[j2].ax,cams[j2].ay,cams[j2].aw,cams[j2].ah)
				for x=0,16 do for y=0,16 do
						local pox,poy=p.oldpos.x,p.oldpos.y
						if pox<0 then pox=math.floor(pox+0.999) end
						if poy<0 then poy=math.floor(poy+0.999) end

				  local px= pixels[posstr(pox-8+x,poy-8+y)]
						if px==2 then px=trc end
						if px then pix(cams[j2].ax+pox-cams[j2].x-8+x,cams[j2].ay+poy-cams[j2].y-8+y,px)
						else pix(cams[j2].ax+pox-cams[j2].x-8+x,cams[j2].ay+poy-cams[j2].y-8+y,0) end
				end end
				end
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				pick_up(j,p.id)
				rem(powerups,i)
				goto endloop
				end
				end
				end
				
				end
				::endloop::
		end
		
		for i=#missiles,1,-1 do
				local ms=missiles[i]
				if ms.oldpos then
						local hyp=7.5
						clear_sprite2(ms,hyp)
				end
		end
		for i=#missiles,1,-1 do
				local ms=missiles[i]
				ms.x=ms.x+ms.dx; ms.y=ms.y+ms.dy
				local hyp=7.5
				for j,s in ipairs(ships) do
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				local a={x=cos(ms.a-pi/4)*hyp,y=sin(ms.a-pi/4)*hyp}; local d={x=cos(ms.a+pi/4)*hyp,y=sin(ms.a+pi/4)*hyp}
				local b={x=cos(ms.a+pi/4)*hyp,y=sin(ms.a+pi/4)*hyp}; local e={x=cos(ms.a-pi+pi/4)*hyp,y=sin(ms.a-pi+pi/4)*hyp}
				local c={x=cos(ms.a-pi+pi/4)*hyp,y=sin(ms.a-pi+pi/4)*hyp}; local f={x=cos(ms.a-pi-pi/4)*hyp,y=sin(ms.a-pi-pi/4)*hyp}
				textri(cams[j].ax-cams[j].x+ms.x+4+a.x,cams[j].ay-cams[j].y+ms.y+4+a.y,
				       cams[j].ax-cams[j].x+ms.x+4+b.x,cams[j].ay-cams[j].y+ms.y+4+b.y,
				       cams[j].ax-cams[j].x+ms.x+4+c.x,cams[j].ay-cams[j].y+ms.y+4+c.y,

				       2*8,2*8,
											2*8+7,2*8,
											2*8,2*8+7, 
											
											false, 0)
				textri(cams[j].ax-cams[j].x+ms.x+4+d.x,cams[j].ay-cams[j].y+ms.y+4+d.y,
				       cams[j].ax-cams[j].x+ms.x+4+e.x,cams[j].ay-cams[j].y+ms.y+4+e.y,
				       cams[j].ax-cams[j].x+ms.x+4+f.x,cams[j].ay-cams[j].y+ms.y+4+f.y,

				       2*8+7,2*8,
											2*8,2*8+7,
											2*8+7,2*8+7, 
											
											false, 0)
				end
				ms.oldpos={x=ms.x,y=ms.y}
				
				if oob(ms.x+4,ms.y+4) then clear_sprite2(ms,hyp); rem(missiles,i); goto endmisl end
				local p= pixels[posstr(ms.x+4,ms.y+4)]
				if p and p>2 then
						clear_sprite2(ms,hyp); rem(missiles,i) 
						explode(ms); goto endmisl
				end
				
				for j,s in ipairs(ships) do
				if ms.owner~=s then
				local points={{x=s.x-cos(s.a)*8,y=s.y-sin(s.a)*8},
	         								{x=s.x-cos(s.a-2*pi/3-0.3)*11,y=s.y-sin(s.a-2*pi/3-0.3)*11},
																		{x=s.x+cos(s.a)*4,y=s.y+4*sin(s.a)},
																		{x=s.x-cos(s.a+2*pi/3+0.3)*11,y=s.y-sin(s.a+2*pi/3+0.3)*11}}
				if PointWithinShape(points,ms.x+4,ms.y+4) then
						dmg(s,6)
						clear_sprite2(ms,hyp)
						rem(missiles,i)
						explode(ms)
						goto endmisl
				end
				end
				end
				::endmisl::
		end
				
		for i=#shots,1,-1 do
				local sh=shots[i]
				if sh.oldpos then
						clear_sprite(sh)
						
						if oob(sh.oldpos.x+3,sh.oldpos.y+3) then
								rem(shots,i)
						end
				end
		end
		for i=#shots,1,-1 do
				local sh=shots[i]
				sh.x=sh.x+sh.dx; sh.y=sh.y+sh.dy
				sh.oldpos={x=sh.x,y=sh.y}
				local wallhits=0
				for lx=0,7 do for ly=0,7 do
						if sprpix(32,lx,ly)~=0 and is_solid(pixels[posstr(sh.x+lx,sh.y+ly)]) then

								for j,s in ipairs(ships) do
								clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
								pix(cams[j].ax-cams[j].x+sh.x+lx,cams[j].ay-cams[j].y+sh.y+ly,1)
								end
								clip()
								
								pixels[posstr(sh.x+lx,sh.y+ly)]=1
								wallhits=wallhits+1
						end
				end end
				if wallhits<=4 or sh.id==50 then
				for j,s in ipairs(ships) do
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				spr(sh.id,cams[j].ax+sh.x-cams[j].x,cams[j].ay+sh.y-cams[j].y,0)
				end
				clip()
				else rem(shots,i) end--; clear_sprite(sh) end
		
				if sh.id==50 then
						sh.t=sh.t or 30
						sh.t=sh.t-1
						if sh.t==0 then 
						clear_sprite(sh)
						rem(shots,i) 
						end
				end
		end
		
		for i=#shots,1,-1 do
				local sh=shots[i]
				if sh.id==32 then

				for j,s in ipairs(ships) do
				if sh.owner~=s then
				local points={{x=s.x-cos(s.a)*8,y=s.y-sin(s.a)*8},
	         								{x=s.x-cos(s.a-2*pi/3-0.3)*11,y=s.y-sin(s.a-2*pi/3-0.3)*11},
																		{x=s.x+cos(s.a)*4,y=s.y+4*sin(s.a)},
																		{x=s.x-cos(s.a+2*pi/3+0.3)*11,y=s.y-sin(s.a+2*pi/3+0.3)*11}}
				if PointWithinShape(points,sh.x+3,sh.y+3) then
						dmg(s,3)
						if sh.id==32 then
						clear_sprite(sh)
						rem(shots,i)
						break
						end
				end
				end
				end

				elseif sh.id==50 then

				for j,s in ipairs(ships) do
				if sh.owner~=s then
				local points={{x=s.x-cos(s.a)*8,y=s.y-sin(s.a)*8},
	         								{x=s.x-cos(s.a-2*pi/3-0.3)*11,y=s.y-sin(s.a-2*pi/3-0.3)*11},
																		{x=s.x+cos(s.a)*4,y=s.y+4*sin(s.a)},
																		{x=s.x-cos(s.a+2*pi/3+0.3)*11,y=s.y-sin(s.a+2*pi/3+0.3)*11}}
				local points2={{x=sh.x+3,y=sh.y},
	         								 {x=sh.x+6,y=sh.y+3},
																		 {x=sh.x+3,y=sh.y+6},
																		 {x=sh.x,y=sh.y+3}}
				for k,pt in ipairs(points2) do
				if PointWithinShape(points,pt.x,pt.y) then
						dmg(s,4)
						break
				end
				end
				end
				end

				end
		end

		for i,lz in ipairs(lazers) do
				if lz.oldpos then clear_sprite2(lz,7.5) end
				if oob(lz.x+4,lz.y+4) then rem(lazers,i) end
				local p=pixels[posstr(lz.x+4,lz.y+4)]
				if p and p>2 then rem(lazers,i) end
		end

		for i=#lazers,1,-1 do
				local lz=lazers[i]
				lz.x=lz.x+lz.dx; lz.y=lz.y+lz.dy
				
				local hyp=7.5
				for j,s in ipairs(ships) do
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)

				local a={x=cos(lz.a-pi/4)*hyp,y=sin(lz.a-pi/4)*hyp}; local d={x=cos(lz.a+pi/4)*hyp,y=sin(lz.a+pi/4)*hyp}
				local b={x=cos(lz.a+pi/4)*hyp,y=sin(lz.a+pi/4)*hyp}; local e={x=cos(lz.a-pi+pi/4)*hyp,y=sin(lz.a-pi+pi/4)*hyp}
				local c={x=cos(lz.a-pi+pi/4)*hyp,y=sin(lz.a-pi+pi/4)*hyp}; local f={x=cos(lz.a-pi-pi/4)*hyp,y=sin(lz.a-pi-pi/4)*hyp}
				textri(cams[j].ax-cams[j].x+lz.x+4+a.x,cams[j].ay-cams[j].y+lz.y+4+a.y,
				       cams[j].ax-cams[j].x+lz.x+4+b.x,cams[j].ay-cams[j].y+lz.y+4+b.y,
				       cams[j].ax-cams[j].x+lz.x+4+c.x,cams[j].ay-cams[j].y+lz.y+4+c.y,

				       3*8,1*8,
											3*8+7,1*8,
											3*8,1*8+7, 
											
											false, 0)
				textri(cams[j].ax-cams[j].x+lz.x+4+d.x,cams[j].ay-cams[j].y+lz.y+4+d.y,
				       cams[j].ax-cams[j].x+lz.x+4+e.x,cams[j].ay-cams[j].y+lz.y+4+e.y,
				       cams[j].ax-cams[j].x+lz.x+4+f.x,cams[j].ay-cams[j].y+lz.y+4+f.y,

				       3*8+7,1*8,
											3*8,1*8+7,
											3*8+7,1*8+7, 
											
											false, 0)
				--spr(19,cams[j].ax+lz.x-cams[j].x,cams[j].ay+lz.y-cams[j].y,0)
				end
				lz.oldpos={x=lz.x,y=lz.y}
				for j,s in ipairs(ships) do
				if lz.owner~=s then
				local points={{x=s.x-cos(s.a)*8,y=s.y-sin(s.a)*8},
	         								{x=s.x-cos(s.a-2*pi/3-0.3)*11,y=s.y-sin(s.a-2*pi/3-0.3)*11},
																		{x=s.x+cos(s.a)*4,y=s.y+4*sin(s.a)},
																		{x=s.x-cos(s.a+2*pi/3+0.3)*11,y=s.y-sin(s.a+2*pi/3+0.3)*11}}
				if PointWithinShape(points,lz.x+4,lz.y+4) then
						dmg(s,1)
						clear_sprite2(lz,7.5)
						rem(lazers,i)
						break
				end
				end
				end
		end

		for i=#static,1,-1 do
				local st=static[i]
				for j,s in ipairs(ships) do
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				for lx=0,7 do for ly=0,7 do
				if sprpix(st.id,lx,ly)~=0 then
						local p= pix(cams[j].ax+st.x+lx-cams[j].x,cams[j].ay+math.floor(st.y+sin(t*0.08)*2.5)+ly-cams[j].y)
						--trace(p)
						--trace(fmt('st.iframes %d',st.iframes))
						if (st.id==49 and st.iframes==0 and p>2 and p~=12) or (st.id==17 and p>4) then
						--trace(fmt('got this far, %d',p))
						
						-- drones may despawn immediately
						st.oldpos=st.oldpos or {x=st.x,y=st.y+sin(t*0.08)*2.5}
						clear_sprite(st)
						st.blownup=true
						goto cleared
						end
				end
				end end
				end
				
				::cleared::
				
				if st.blownup then
				rem(static,i)
				for j,sh in ipairs(shots) do
						if AABB(sh.x,sh.y,7,7,st.x,st.y+sin(t*0.08)*2.5,8,8) then
								clear_sprite(sh)
								rem(shots,j)
								break
						end
				end
				for j,ms in ipairs(missiles) do
						if AABB(ms.x,ms.y,8,8,st.x,st.y+sin(t*0.08)*2.5,8,8) then
								clear_sprite2(ms,7.5)
								rem(missiles,j)
								break
						end
				end
				if st.id==49 then explode(st) end
				goto blowup
				end
				
				for j,s in ipairs(ships) do
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				spr(st.id,cams[j].ax+st.x-cams[j].x,cams[j].ay+st.y-cams[j].y+sin(t*0.08)*2.5,0,1,0,0,1,1)
				end

				st.oldpos={x=st.x,y=st.y+sin(t*0.08)*2.5}

				for j,s in ipairs(ships) do
				--clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				
				if st.id==49 and st.iframes==0 then
				local points={{x=s.x,y=s.y},
																		{x=s.x-cos(s.a)*8,y=s.y-sin(s.a)*8},
	         								{x=s.x-cos(s.a-2*pi/3-0.3)*11,y=s.y-sin(s.a-2*pi/3-0.3)*11},
																		{x=s.x+cos(s.a)*4,y=s.y+4*sin(s.a)},
																		{x=s.x-cos(s.a+2*pi/3+0.3)*11,y=s.y-sin(s.a+2*pi/3+0.3)*11}}
				for k,pt in ipairs(points) do
				if math.sqrt((pt.x-(st.oldpos.x+4))^2+(pt.y-(st.oldpos.y+4))^2)<=4 then
						clear_sprite(st)
						dmg(s,6)
						rem(static,i)
						explode(st)
						goto blowup
				end end
				end end

				if st.id==49 and st.iframes>0 then st.iframes=st.iframes-1 end
				
				::blowup::
				clip()
		end

		for i=#explosions,1,-1 do
				local exp=explosions[i]
				for j,s in ipairs(ships) do
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				for x=exp.x-(exp.r+1),exp.x+(exp.r+1)+1 do for y=exp.y-(exp.r+1),exp.y+(exp.r+1)+1 do
						local p= pixels[posstr(x,y)]
						if not p then
								pix(cams[j].ax-cams[j].x+x,cams[j].ay-cams[j].y+y,0)
						else 
						if p==2 then p=trc end
						if is_solid(p) and math.sqrt((x-exp.x)^2+(y-exp.y)^2)<=exp.r+1 then p=1; pixels[posstr(x,y)]=1 end
						pix(cams[j].ax-cams[j].x+x,cams[j].ay-cams[j].y+y,p) end
				end end
				end
				clip()
		end

		for j,s in ipairs(ships) do
				s.damaged=nil
		end
		for i=#explosions,1,-1 do
				local exp=explosions[i]
				
				for k=#shots,1,-1 do
						local sh=shots[k]
						if sh.id==32 and math.sqrt((exp.x-(sh.x+3))^2+(exp.y-(sh.y+3))^2)<=exp.r then
								clear_sprite(sh); rem(shots,k)
						end
				end

				for k=#missiles,1,-1 do
						local ms=missiles[k]
						if math.sqrt((exp.x-(ms.x+4))^2+(exp.y-(ms.y+4))^2)<=exp.r then
								clear_sprite2(ms,7.5); explode(ms); rem(missiles,k)
						end
				end
				
				for k=#static,1,-1 do
						local st=static[k]
						if st.id==17 and math.sqrt((exp.x-(st.x+4))^2+(exp.y-(st.y+4))^2)<=exp.r then
								clear_sprite(st); rem(static,k)
						end
				end

				for j,s in ipairs(ships) do
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				circ(cams[j].ax-cams[j].x+exp.x,cams[j].ay-cams[j].y+exp.y,exp.r,4-(60-exp.t)*0.2)
				local points={{x=s.x,y=s.y},
																		{x=s.x-cos(s.a)*8,y=s.y-sin(s.a)*8},
	         								{x=s.x-cos(s.a-2*pi/3-0.3)*11,y=s.y-sin(s.a-2*pi/3-0.3)*11},
																		{x=s.x+cos(s.a)*4,y=s.y+4*sin(s.a)},
																		{x=s.x-cos(s.a+2*pi/3+0.3)*11,y=s.y-sin(s.a+2*pi/3+0.3)*11}}
				for k,pt in ipairs(points) do
				if not s.damaged and math.sqrt((exp.x-pt.x)^2+(exp.y-pt.y)^2)<=exp.r then
						dmg(s,0.5); s.damaged=true; break
				end end
				end

				if exp.r==6 then ins(explosions,{x=exp.x+math.random(-12,12),y=exp.y+math.random(-12,12),t=60,gen=exp.gen+1,r=math.random(12-(exp.gen+1),16-(exp.gen+1))}) end
				if exp.r==0 then rem(explosions,i) end
				exp.r=exp.r-1
				exp.t=exp.t-1
		end
end

explosions={}

function explode(e)
		for i=1,3 do
		ins(explosions,{x=e.x,y=e.y,t=60,gen=0,r=math.random(12,16)})
		end
end

function clear_sprite(sh)
		for lx=0,8 do for ly=0,8 do
				--if ly==8 or sprpix(sh.id,lx,ly)~=0 then
						for j,s in ipairs(ships) do
						clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
						local px,py=sh.oldpos.x,sh.oldpos.y
						-- for precision in flooring negatives
						if px+lx-cams[j].x<0 then px=px+1 end
						if py+ly-cams[j].y<0 then py=py+1 end
						local p=pixels[posstr(px+lx,py+ly)]

						if not p then
								pix(cams[j].ax-cams[j].x+px+lx,cams[j].ay-cams[j].y+py+ly,0)
						else 
						if p==2 then p=trc end
						pix(cams[j].ax-cams[j].x+px+lx,cams[j].ay-cams[j].y+py+ly,p) end
						end
						clip()
				--end
		end end
end

-- for textri objects
function clear_sprite2(ms,hyp)
		for j,s in ipairs(ships) do
		clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
		if ms.oldpos then 
		for x=ms.oldpos.x+4-hyp,ms.oldpos.x+4+hyp do for y=ms.oldpos.y+4-hyp,ms.oldpos.y+4+hyp do
				local px=pixels[posstr(x,y)]
				if px then 
				if px==2 then px=trc end
				pix(cams[j].ax+x-cams[j].x,cams[j].ay+y-cams[j].y,px)
				else pix(cams[j].ax+x-cams[j].x,cams[j].ay+y-cams[j].y,0) end
		end end
		end
		end
end

inventory={}

function pick_up(j,pwrid,silent)
		if not inventory[j] then inventory[j]={} end
		local full=true
		for i=1,9 do
				if not inventory[j][i] then
						inventory[j][i]={id=pwrid}
						for k=1,9 do
								if not inventory[j][k] then full= false break end
						end
						break
				end
				if i==9 then return end
		end
		if not silent then alert(j,fmt('Picked up %s.',idtag(pwrid)),true) end
		if full then alert(j,'Inventory is now full.') end
end

idtags={
		[32]={'Blaster',nrj=40},
		[17]={'Drone',nrj=4},
		[34]={'Missile',nrj=7},
		[49]={'Mine',nrj=9},
		[50]={'Plasma',nrj=14},
		[19]={'AutoLazer',nrj=999},
		[21]={'AutoAim.MOD',nrj=999},
		[51]={'Thruster',nrj=999},
}
scrapvals={
		[32]={40},
		[17]={20,spawn=19},
		[34]={50,spawn=51},
		[49]={35},
		[50]={50},
		[19]={10,spawn=21},		
		[21]={10},
		[51]={30},
}

function idtag(id)
		return idtags[id][1]
end

function dmg(s,n)
		n=n or 3
		s.hp=s.hp-n
		if s.hp<=0 then s.gone=true end
		s.flash=18
end

function shipdraw(j)
		local cam=cams[j]
		for k,s in ipairs(ships) do
		points={{s.x-cos(s.a)*8,s.y-sin(s.a)*8},
	         {s.x-cos(s.a-2*pi/3-0.3)*11,s.y-sin(s.a-2*pi/3-0.3)*11},
										{s.x+cos(s.a)*4,s.y+4*sin(s.a)},
										{s.x-cos(s.a+2*pi/3+0.3)*11,s.y-sin(s.a+2*pi/3+0.3)*11}}
		--[[for i,v in ipairs(points) do
				if pix(v[1],v[2])==2 then
						transition(v[1],v[2])
						break
				end
		end]]
		if not s.trans then
		local c=13
		if s.flash then c=2; s.flash=s.flash-1; if s.flash==0 then s.flash=nil end end
		for i,v in ipairs(points) do
				if i<#points then
				line(cam.ax+v[1]-cam.x,cam.ay+v[2]-cam.y,cam.ax+points[i+1][1]-cam.x,cam.ay+points[i+1][2]-cam.y,c)
				else
				line(cam.ax+v[1]-cam.x,cam.ay+v[2]-cam.y,cam.ax+points[1][1]-cam.x,cam.ay+points[1][2]-cam.y,c)
				end
		end
		end
		--pix(cam.ax+s.x-cam.x,cam.ay+s.y-cam.y,2)
		end
end

keymap={}

function UIdraw(j)
		
		local s=ships[j]
		local cam=cams[j]

		local rw=s.hp/30*(cam.aw-8)
		rect(cam.ax+4,cam.ay+3,rw,2,6)
		for i=1,2 do
		if s[fmt('shot%d',i)] then
		rw=s[fmt('shot%d',i)].nrj/max_nrj(j,i)*((cam.aw-4*3)/2)
		rect(cam.ax+4+(i-1)*((cam.aw-4*3)/2+4),cam.ay+cam.ah-1-4,rw,2,1)
		end
		end
		
		if alerts[j] then
				local c,c2=2,4
				if alerts[j].t<20 or alerts[j].t>160-20 then c,c2=1,3 end
				if alerts[j].msgs[1].goodnews then 
				c,c2=6,4
				if alerts[j].t<20 or alerts[j].t>160-20 then c,c2=7,5 end
				end
				
				rect(cam.ax,cam.ay,cam.aw,8,c)
				local tw=print(alerts[j].msgs[1][1],0,-6,c2,false,1,true)
				print(alerts[j].msgs[1][1],cam.ax+cam.aw/2-tw/2,cam.ay+1,c2,false,1,true)

				alerts[j].t=alerts[j].t-1
				if alerts[j].t==0 then rem(alerts[j].msgs,1); if #alerts[j].msgs==0 then alerts[j]=nil else alerts[j].t=160 end end
		end
		
		if s.onbase then
				local cx,cy=cam.aw/2,cam.ah/2
				inventory[j].i=inventory[j].i or 1

				local function actuallen(inv)
						-- for inventories that contain holes
						for i=9-1,0,-1 do
								if inv[i+1] then return i+1 end
						end
						return 0
				end

				local scrapping=false				
				for i=2,5 do
						if btn((s.id-1)*8+i) then
								if not keymap[j] or not (keymap[j][i]==2) then
								if not keymap[j] then keymap[j]={} end
								keymap[j][(s.id-1)+i]=1
								end
						else
								if keymap[j] and keymap[j][(s.id-1)+i]==1 then
										if i==2 then 
										if btn((s.id-1)*8+4) then
										scrapping=true; keymap[j][(s.id-1)*8+4]=2
										else inventory[j].i=inventory[j].i-1; if inventory[j].i<1 then inventory[j].i=actuallen(inventory[j]); if inventory[j].i<1 then inventory[j].i=1 end end 
										end
										end
										if i==3 then inventory[j].i=inventory[j].i+1; if inventory[j].i>actuallen(inventory[j]) then inventory[j].i=1 end end
										if i==4 then
										if btn((s.id-1)*8+2) then
										scrapping=true; keymap[j][(s.id-1)*8+2]=2
										else if inventory[j][inventory[j].i] then local oldshot1=s.shot1; if oldshot1 then inventory[j][oldshot1.invi].nrj=oldshot1.nrj end; s.shot1={invi=inventory[j].i,nrj=inventory[j][inventory[j].i].nrj or idtags[inventory[j][inventory[j].i].id].nrj}; if s.shot2 and s.shot2.invi==inventory[j].i then s.shot2=nil end end 
										end
										end
										if i==5 then if inventory[j][inventory[j].i] then local oldshot2=s.shot2; if oldshot2 then inventory[j][oldshot2.invi].nrj=oldshot2.nrj end; s.shot2={invi=inventory[j].i,nrj=inventory[j][inventory[j].i].nrj or idtags[inventory[j][inventory[j].i].id].nrj}; if s.shot1 and s.shot1.invi==inventory[j].i then s.shot1=nil end end 
										end
								end
								if keymap[j] then keymap[j][(s.id-1)+i]=nil end
						end
				end
				if scrapping then
				local id=inventory[j][inventory[j].i].id 
				inventory[j][inventory[j].i]=nil 
				local scrapres=scrapvals[id]
				if scrapres.spawn then inventory[j][inventory[j].i]={id=scrapres.spawn}; alert(j,fmt('Got %s!',idtags[scrapres.spawn][1]),true) end
				scrap[ships[j].id]=scrap[ships[j].id]+scrapres[1]
				alert(j,fmt('Got %d scrap.',scrapres[1]),true)
				if s.shot1 and s.shot1.invi==inventory[j].i then s.shot1=nil end
				if s.shot2 and s.shot2.invi==inventory[j].i then s.shot2=nil end 
				end

				local idtag_tw=nil
				local idtag_tx=nil
				for i=0,9-1 do
						if i+1==inventory[j].i then 
								if inventory[j][i+1] then
								local tw=print(idtags[inventory[j][i+1].id][1],0,-6,12,false,1,true)
								idtag_tw=tw
								local tx=cam.ax+cx-6*9+i*12+6-tw/2+1
								if tx<cam.ax then tx=cam.ax+1 end
								if tx>cam.ax+cam.aw-tw then tx=cam.ax+cam.aw-tw end
								idtag_tx=tx
								dropshadow(idtags[inventory[j][i+1].id][1],tx,cam.ay+cy+6+2,true)
								print(idtags[inventory[j][i+1].id][1],tx,cam.ay+cy+6+2,12,false,1,true)
								end
						end
				end
				for i=0,9-1 do
						rect(cam.ax+cx-6*9+i*12+2,cam.ay+cy-6+2,8,8,0)
						local selsp=68
						if i+1==inventory[j].i then 
								for x=0,12-1 do for y=0,12-1 do
										selsp=68 
										if x>=8 then selsp=selsp+1 end
										if y>=8 then selsp=selsp+16 end
										local px=sprpix(selsp,x%8,y%8)
										if px==12 then 
												local pulse=(t*0.3)%7
												if pulse>4 then pulse=7-pulse end
												px=pulse+1
										end
										if px~=0 then pix(cam.ax+cx-6*9+i*12+x,cam.ay+cy-6+y,px) end
								end end

						else spr(selsp,cam.ax+cx-6*9+i*12,cam.ay+cy-6,0,1,0,0,2,2) end
						if inventory[j][i+1] then
								spr(inventory[j][i+1].id,cam.ax+cx-6*9+i*12+2,cam.ay+cy-6+2,0)
						end
						if s.shot2 and i+1==s.shot2.invi then
								local tw=print('S2',0,-6,12)
								local th=0
								if idtag_tw and AABB(idtag_tx,cam.ay+cy+6+2,idtag_tw,5,cam.ax+cx-6*9+i*12+1,cam.ay+cy-6+12+2,tw,5) then th=6+2 end
								dropshadow('S2',cam.ax+cx-6*9+i*12+1,cam.ay+cy-6+12+2+th)
								print('S2',cam.ax+cx-6*9+i*12+1,cam.ay+cy-6+12+2+th,12)
						end
						if s.shot1 and i+1==s.shot1.invi then
								local tw=print('S1',0,-6,12)
								local th=0
								if idtag_tw and AABB(idtag_tx,cam.ay+cy+6+2,idtag_tw,5,cam.ax+cx-6*9+i*12+1,cam.ay+cy-6+12+2,tw,5) then th=6+2 end
								dropshadow('S1',cam.ax+cx-6*9+i*12+1,cam.ay+cy-6+12+2+th)
								print('S1',cam.ax+cx-6*9+i*12+1,cam.ay+cy-6+12+2+th,12)
						end
				end
				if not s.moved and not (s.shot1 or s.shot2) then
						local tw= print('Select weapons.',0,-6,12,false,1,true)
						dropshadow('Select weapons.',cam.ax+cx-tw/2,cam.ay+cy-6-8,true)
						print('Select weapons.',cam.ax+cx-tw/2,cam.ay+cy-6-8,12,false,1,true)
				end
				if not s.moved and (s.shot1 or s.shot2) then
						local tw= print('Move up to leave base.',0,-6,12,false,1,true)
						dropshadow('Move up to leave base.',cam.ax+cx-tw/2,cam.ay+cy-6-8,true)
						print('Move up to leave base.',cam.ax+cx-tw/2,cam.ay+cy-6-8,12,false,1,true)
				end
		end
end

function dropshadow(msg,x,y,smallfont)
		print(msg,x-1,y,0,false,1,smallfont)
		print(msg,x+1,y,0,false,1,smallfont)
		print(msg,x,y-1,0,false,1,smallfont)
		print(msg,x,y+1,0,false,1,smallfont)
end

pixels={}
local seed=math.random(120948087)--89828907
trace(seed)

function load()
		cls(0)
		px,py=px or 0,py or 0

		if py==136*2-1 then
				cls(0)

				create_powerups()

				ships[1]=create_base(1,0,240-1,0,136-1)
				if players>=2 then ships[2]=create_base(2,240,240*2-1,136,136*2-1) end
				if players>=3 then ships[3]=create_base(3,240,240*2-1,0,136-1) end
				if players>=4 then ships[4]=create_base(4,0,240-1,136,136*2-1) end

				for j=1,4 do
				if j>players then break end
				cam_init(j)
				end

				TIC=update; trace('Generation complete.')
				return
		end
		
		for x=px,math.min(px+64,240*2-1) do for y=py,math.min(py+64,136*2-1) do 
			if (y>=134 and y<138) or (x>=238 and x<242) then pixels[posstr(x,y)]=2 end
			local per=perlin(x*0.015,y*0.015,seed)
			if per>0.55 then
					pixels[posstr(x,y)]=13
					--pix(x,y,14)
			elseif per>0.5 then
					pixels[posstr(x,y)]=14
			elseif per>0.475 then
					if (x+y)%2==0 then pixels[posstr(x,y)]=15
					else pixels[posstr(x,y)]=14 end
			elseif per>0.45 then
					pixels[posstr(x,y)]=15
			end
			--[[if perlin(x*0.015,y*0.015,seed)>0.525 then
					if (x+y)%2==0 then pixels[posstr(x,y)]=14
					else pixels[posstr(x,y)]=13 end
			end]]
			--trace(fmt('x:%d y:%d px:%d py:%d',x,y,px,py))
		end 
		end
		px=px+64; if px>=240*2-1 then
				py=py+64
				px=0
				--trace(fmt('px:%d py:%d',px,py))
				if py>=136*2-1 then
						py=136*2-1
				end
		end
		
		local tw=print(fmt('Generating map %d...',seed),0,-6)
		print(fmt('Generating map %d...',seed),240/2-tw/2,136/2+12)
		rectb(8,136/2-2,240-20+4,12,13)
		rect(10,136/2,py/(136*2-1)*(240-20),8,6)
end

function create_base(j,minx,maxx,miny,maxy)
		--cls(0)
		local rx,ry=math.random(minx,maxx),math.random(miny,maxy)
		while pixels[posstr(rx,ry)] do
		rx,ry=math.random(minx,maxx),math.random(miny,maxy)
		end
		while not pixels[posstr(rx,ry)] and not oob(rx,ry) do
		ry=ry+1
		end
		if pixels[posstr(rx,ry)]==2 or oob(rx,ry) or oob(rx,ry-16) or is_solid(pixels[posstr(rx,ry-16)]) then trace('bad spawn, rerolling'); return create_base(j,minx,maxx,miny,maxy) end
		--spr(64,rx-12-minx,ry-6-miny,0,1,0,0,3,1)
		for x=0,24-1 do for y=2,8-1 do
		--if pix(x-minx,y-miny)~=0 then pixels[posstr(x,y)]=pix(x,y) end
		local sp= sprpix(64+math.floor(x/8),x%8,y)
		if sp~=0 then
				pixels[posstr(rx-12+x,ry-6+y-2)]=sp
		end
		end end
		--cams[j].sx=minx; cams[j].sy=miny
		local newship={x=rx,y=ry-16,a=pi/2,oldx=rx,oldy=ry-16,hp=30,id=j}
		pick_up(j,32,true) -- starting weapon 1: Blaster
		pick_up(j,49,true) -- starting weapon 2: Mine
		pick_up(j,17,true)
		--pick_up(j,50,true)
		pick_up(j,34,true)
		return newship
end

powerups={}

function create_powerups()
		for i=1,5 do
		create_powerup(0,240*2-1,0,136*2-1)
		end
end

function create_powerup(minx,maxx,miny,maxy,type)
		local rx,ry=math.random(minx,maxx),math.random(miny,maxy)
		while pixels[posstr(rx,ry)] do
		rx,ry=math.random(minx,maxx),math.random(miny,maxy)
		end
		local type=type or math.random(1,5)
		local id
		if type==1 then id=32 end
		if type==2 then id=17 end
		if type==3 then id=34 end
		if type==4 then id=49 end
		if type==5 then id=50 end
		
		ins(powerups,{x=rx,y=ry,id=id})
end

cycle={i=1}

function mainmenu()
		cls(0)
		for i=1,4 do
		print('LUALA',180-40-40+16-(i*4),40-20+16-(i*4)-8,i,false,4,false)
		end
		--print('Version 1c',180-40-40+40+2,40+4*6-20+10,13,false,1,true)
		print('Version 1d',2,136-8,13,false,1,true)

		if btnp(0) or btnp(2) then cycle.i=cycle.i-1; if cycle.i<1 then cycle.i=4 end end
		if btnp(1) or btnp(3) then cycle.i=cycle.i+1; if cycle.i>4 then cycle.i=1 end end

		if btnp(4) then players=cycle.i; TIC=load end

		for i=1,4 do
				local msg
				if i==1 then msg='Solo (Practice)'
				else msg=fmt('%d players',i) end
				local c=13
				if i==cycle.i then c=8+(t*0.3)%8 end
				print(msg,40+(i-1)*50,60+(i-1)*20,c)
				
				if i==1 then 
				local pulse=(t*0.3)%7
				if pulse>4 then pulse=7-pulse end
				rect(5+(cycle.i-1)*50,60+(cycle.i-1)*20-7,31,19,1+pulse) 
				end
				
				if i==1 then rectb(5+(i-1)*50,60+(i-1)*20-7,31,19,13) end
				if i==2 then rectb(5+(i-1)*50,60+(i-1)*20-7,31,19,13); rectb(5+(i-1)*50,60+(i-1)*20-7,16,19,13) end
				if i==3 then rectb(5+(i-1)*50,60+(i-1)*20-7,31,10,13); rectb(5+(i-1)*50,60+(i-1)*20-7,16,10,13); rectb(5+(i-1)*50+8,60+(i-1)*20-7+9,16,10,13) end
				if i==4 then rectb(5+(i-1)*50,60+(i-1)*20-7,31,10,13); rectb(5+(i-1)*50,60+(i-1)*20-7,16,10,13); rectb(5+(i-1)*50,60+(i-1)*20-7+9,31,10,13); rectb(5+(i-1)*50,60+(i-1)*20-7+9,16,10,13) end
		end
		t=t+1
end

TIC=mainmenu

function transition(j,s,tx,ty)
		if ty>=134 and ty<136 and not oob(cams[j].sx,cams[j].sy+136) and s.dy>0 then
				cams[j].sy=cams[j].sy+136
				s.trans=true
		end
		if ty>=0 and ty<2 and not oob(cams[j].sx,cams[j].sy-136) and s.dy<0 then
				cams[j].sy=cams[j].sy-136
				s.trans=true
		end
		if tx>=238 and tx<240 and not oob(cams[j].sx+240,cams[j].sy) and s.dx>0 then
				cams[j].sx=cams[j].sx+240
				s.trans=true
		end
		if tx>=0 and tx<2 and not oob(cams[j].sx-240,cams[j].sy) and s.dx<0 then
				cams[j].sx=cams[j].sx-240
				s.trans=true
		end
		if s.trans then
				transalert(j)
				renderwindow(j)		
		end
end

function forcetransition(j,s,tx,ty)
		if ty>=136 and s.dy>0 then
				cams[j].sy=cams[j].sy+136
				s.trans=true
		end
		if ty<0 and s.dy<0 then
				cams[j].sy=cams[j].sy-136
				s.trans=true
		end
		if tx>=240 and s.dx>0 then
				cams[j].sx=cams[j].sx+240
				s.trans=true
		end
		if tx<0 and s.dx<0 then
				cams[j].sx=cams[j].sx-240
				s.trans=true
		end
		if s.trans then
				transalert(j)
				renderwindow(j)
		end
end

function transalert(j)
		for i,s in ipairs(ships) do
				if i~=j then
						if cams[j].sx==cams[i].sx and cams[j].sy==cams[i].sy then
								alert(i,'Enemy detected nearby!')
						end
				end
		end
end

alerts={}

function alert(j,msg,goodnews)
		if alerts[j] then if alerts[j].msgs[#alerts[j].msgs][1]~=msg then ins(alerts[j].msgs,{msg,goodnews=goodnews}) end
		else	alerts[j]={msgs={{msg,goodnews=goodnews}},t=160} end
end

function oob(x,y)
		return x<0 or y<0 or x>=240*2 or y>=136*2
end

function is_solid(px)
		return px==13 or px==14 or px==15
end

-- my Lua implementation of Perlin noise
-- from August 2019.

		function perlin(x,y,z)
		  --Perlin noise by Ken Perlin,
		  --inventor of Perlin noise
		  --and winner of Academy Award for Perlin noise,
		  --which is his invention.
		  xi=math.floor(x)%256; --if xi>255 then xi=255 end
		  yi=math.floor(y)%256; --if yi>255 then yi=255 end
		  zi=math.floor(z)%256; --if zi>255 then zi=255 end
		  xf=x-math.floor(x)
		  yf=y-math.floor(y)
		  zf=z-math.floor(z)
		  u=fade(xf)
		  v=fade(yf)
		  w=fade(zf)
		  
		  local p=per_p
		  aaa = p[p[p[    xi ]+    yi ]+    zi ]
		  aba = p[p[p[    xi ]+  yi+1 ]+    zi ]
		  aab = p[p[p[    xi ]+    yi ]+  zi+1 ]
		  abb = p[p[p[    xi ]+  yi+1 ]+  zi+1 ]
		  baa = p[p[p[  xi+1 ]+    yi ]+    zi ]
		  bba = p[p[p[  xi+1 ]+  yi+1 ]+    zi ]
		  bab = p[p[p[  xi+1 ]+    yi ]+  zi+1 ]
		  bbb = p[p[p[  xi+1 ]+  yi+1 ]+  zi+1 ]
		
		  x1=lerp(grad(aaa,xf,yf,zf),
		          grad(baa,xf-1,yf,zf),
		          u)
		  x2=lerp(grad(aba,xf,yf-1,zf),
		          grad(bba,xf-1,yf-1,zf),
		          u)
		  y1=lerp(x1,x2,v)
		
		  x1=lerp(grad(aab,xf,yf,zf-1),
		          grad(bab,xf-1,yf,zf-1),
		          u)
		  x2=lerp(grad(abb,xf,yf-1,zf-1),
		          grad(bbb,xf-1,yf-1,zf-1),
		          u)
		  y2=lerp(x1,x2,v)
		
		
		  return (lerp(y1,y2,w)+1)/2
		
		end
		
		function fade(tt)
		  return tt*tt*tt*(tt*(tt*6-15)+10)
		end
		
		function grad(hash,x,y,z)
		  hash=hash%16
		  
		  if hash==0 then return x+y end
		  if hash==1 then return -x+y end
		  if hash==2 then return x-y end
		  if hash==3 then return -x-y end
		  if hash==4 then return x+z end
		  if hash==5 then return -x+z end
		  if hash==6 then return x-z end
		  if hash==7 then return -x-z end
		  if hash==8 then return y+z end
		  if hash==9 then return -y+z end
		  if hash==10 then return y-z end
		  if hash==11 then return -y-z end
		  if hash==12 then return y+x end
		  if hash==13 then return -y+z end
		  if hash==14 then return y-x end
		  if hash==15 then return -y-z end
		end
		
		function lerp(a,b,x)
		  return a+x * (b-a)
		end
		
		--https://xkcd.com/221/
		permutation = {151,160,137,91,90,15,
		   131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
		   190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
		   88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
		   77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
		   102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
		   135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
		   5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
		   223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
		   129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
		   251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
		   49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
		   138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180}
		per_p = {}
		for i=0,512-1 do
		  per_p[i] = permutation[i%256+1]
		end

-- you give this the numbers 0 and 1, it will return a string '0:1'.
-- table keys use this format consistently. 
    function posstr(x,y)
        return fmt('%d:%d',math.floor(x),math.floor(y))
    end

-- you give this the string '0:1', it will return 0 and 1. 
    function strpos(pos)
        local delim=string.find(pos,':')
        local x=sub(pos,1,delim-1)
        local y=sub(pos,delim+1)
        --important tonumber calls
        --Lua will handle a string+number addition until it doesn't
        return tonumber(x),tonumber(y)
    end

-- from 1THRUSTR.EXE
		function sprpix(sprno,px,py)
				local byte= peek(0x4000 + 32*sprno + py*4 + px/2)
				if px%2==1 then byte=(byte&0xf0)>>4 
				else byte=byte&0x0f end
				return byte
		end

-- from https://love2d.org/wiki/PointWithinShape

		function PointWithinShape(shape, tx, ty)
		  if #shape == 0 then 
		    return false
		  elseif #shape == 1 then 
		    return shape[1].x == tx and shape[1].y == ty
		  elseif #shape == 2 then 
		    return PointWithinLine(shape, tx, ty)
		  else 
		    return CrossingsMultiplyTest(shape, tx, ty)
		  end
		end
		 
		function BoundingBox(box, tx, ty)
		  return  (box[2].x >= tx and box[2].y >= ty)
		    and (box[1].x <= tx and box[1].y <= ty)
		    or  (box[1].x >= tx and box[2].y >= ty)
		    and (box[2].x <= tx and box[1].y <= ty)
		end
		 
		function colinear(line, x, y, e)
		  e = e or 0.1
		  m = (line[2].y - line[1].y) / (line[2].x - line[1].x)
		  local function f(x) return line[1].y + m*(x - line[1].x) end
		  return math.abs(y - f(x)) <= e
		end
		 
		function PointWithinLine(line, tx, ty, e)
		  e = e or 0.66
		  if BoundingBox(line, tx, ty) then
		    return colinear(line, tx, ty, e)
		  else
		    return false
		  end
		end
		 
		-------------------------------------------------------------------------
		-- The following function is based off code from
		-- [ http://erich.realtimerendering.com/ptinpoly/ ]
		--
		--[[
		 ======= Crossings Multiply algorithm ===================================
		 * This version is usually somewhat faster than the original published in
		 * Graphics Gems IV; by turning the division for testing the X axis crossing
		 * into a tricky multiplication test this part of the test became faster,
		 * which had the additional effect of making the test for "both to left or
		 * both to right" a bit slower for triangles than simply computing the
		 * intersection each time.  The main increase is in triangle testing speed,
		 * which was about 15% faster; all other polygon complexities were pretty much
		 * the same as before.  On machines where division is very expensive (not the
		 * case on the HP 9000 series on which I tested) this test should be much
		 * faster overall than the old code.  Your mileage may (in fact, will) vary,
		 * depending on the machine and the test data, but in general I believe this
		 * code is both shorter and faster.  This test was inspired by unpublished
		 * Graphics Gems submitted by Joseph Samosky and Mark Haigh-Hutchinson.
		 * Related work by Samosky is in:
		 *
		 * Samosky, Joseph, "SectionView: A system for interactively specifying and
		 * visualizing sections through three-dimensional medical image data",
		 * M.S. Thesis, Department of Electrical Engineering and Computer Science,
		 * Massachusetts Institute of Technology, 1993.
		 *
		 --]]
		 
		--[[ Shoot a test ray along +X axis.  The strategy is to compare vertex Y values
		 * to the testing point's Y and quickly discard edges which are entirely to one
		 * side of the test ray.  Note that CONVEX and WINDING code can be added as
		 * for the CrossingsTest() code; it is left out here for clarity.
		 *
		 * Input 2D polygon _pgon_ with _numverts_ number of vertices and test point
		 * _point_, returns 1 if inside, 0 if outside.
		 --]]
		function CrossingsMultiplyTest(pgon, tx, ty)
		  local i, yflag0, yflag1, inside_flag
		  local vtx0, vtx1
		 
		  local numverts = #pgon
		 
		  vtx0 = pgon[numverts]
		  vtx1 = pgon[1]
		
		  -- get test bit for above/below X axis
		  yflag0 = ( vtx0.y >= ty )
		  inside_flag = false
		 
		  for i=2,numverts+1 do
		    yflag1 = ( vtx1.y >= ty )
		 
		    --[[ Check if endpoints straddle (are on opposite sides) of X axis
		     * (i.e. the Y's differ); if so, +X ray could intersect this edge.
		     * The old test also checked whether the endpoints are both to the
		     * right or to the left of the test point.  However, given the faster
		     * intersection point computation used below, this test was found to
		     * be a break-even proposition for most polygons and a loser for
		     * triangles (where 50% or more of the edges which survive this test
		     * will cross quadrants and so have to have the X intersection computed
		     * anyway).  I credit Joseph Samosky with inspiring me to try dropping
		     * the "both left or both right" part of my code.
		     --]]
		    if ( yflag0 ~= yflag1 ) then
		      --[[ Check intersection of pgon segment with +X ray.
		       * Note if >= point's X; if so, the ray hits it.
		       * The division operation is avoided for the ">=" test by checking
		       * the sign of the first vertex wrto the test point; idea inspired
		       * by Joseph Samosky's and Mark Haigh-Hutchinson's different
		       * polygon inclusion tests.
		       --]]
		      if ( ((vtx1.y - ty) * (vtx0.x - vtx1.x) >= (vtx1.x - tx) * (vtx0.y - vtx1.y)) == yflag1 ) then
		        inside_flag =  not inside_flag
		      end
		    end
		 
		    -- Move to the next pair of vertices, retaining info as possible.
		    yflag0  = yflag1
		    vtx0    = vtx1
		    vtx1    = pgon[i]
		  end
		 
		  return  inside_flag
		end
		 
		function GetIntersect( points )
		  local g1 = points[1].x
		  local h1 = points[1].y
		 
		  local g2 = points[2].x
		  local h2 = points[2].y
		 
		  local i1 = points[3].x
		  local j1 = points[3].y
		 
		  local i2 = points[4].x
		  local j2 = points[4].y
		 
		  local xk = 0
		  local yk = 0
		 
		  if checkIntersect({x=g1, y=h1}, {x=g2, y=h2}, {x=i1, y=j1}, {x=i2, y=j2}) then
		    local a = h2-h1
		    local b = (g2-g1)
		    local v = ((h2-h1)*g1) - ((g2-g1)*h1)
		 
		    local d = i2-i1
		    local c = (j2-j1)
		    local w = ((j2-j1)*i1) - ((i2-i1)*j1)
		 
		    xk = (1/((a*d)-(b*c))) * ((d*v)-(b*w))
		    yk = (-1/((a*d)-(b*c))) * ((a*w)-(c*v))
		  else
		    xk,yk = 0,0
		  end
		  return xk, yk
		end
-- <TILES>
-- 002:00ddd0000fdddf00efeeefe0eedddee0ffeeeff0eedddee00000000000000000
-- 004:00ddd0000fdddf00efeeefe0eedddee0ffeeeff0eedddee00234320000222000
-- 007:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 008:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 009:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 010:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:000000000001100000211200d322223dd332233d013333100001100000000000
-- 019:0002000000131000002320000024200000242000002320000013100000020000
-- 021:0000000000200200002222000034430000211200002002000010010000000000
-- 023:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 024:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 025:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 026:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 032:000c000000ccc0000ccccc00ccccccc00ccccc0000ccc000000c000000000000
-- 034:0006700000055000000550000075570006566560056556500570075005000050
-- 036:000000cc0000ccdd000cdde000cde0000cde00000cd00000cde00000cd000000
-- 037:cc000000ddcc00000eddc000000edc000000edc000000dc000000edc000000dc
-- 049:0000000001011010001231000122231001111110001231000101101000000000
-- 050:000200000023200002343200234c432002343200002320000002000000000000
-- 051:0000000000ddd0000fdddf00efeeefe0eedddee0ffeeeff0eedddee000000000
-- 052:cd000000cde000000cd000000cde000000cde000000cdde00000ccdd000000cc
-- 053:000000dc00000edc00000dc00000edc0000edc000eddc000ddcc0000cc000000
-- 064:00000000000000000000765c0065cccc05ccc5605cc56000cc500000c5000000
-- 065:0000000000000000cccccccc5670076500000000000000000000000000000000
-- 066:0000000000000000c5670000cccc5600065ccc5000065cc5000005cc0000005c
-- 068:0cccc00ccdddd00dcd000000cd000000cd0000000000000000000000cd000000
-- 069:ccc00000dddc000000dc000000dc000000dc0000000000000000000000dc0000
-- 084:cd000000cd000000cdddd00d0cccc00c00000000000000000000000000000000
-- 085:00dc000000dc0000dddc0000ccc0000000000000000000000000000000000000
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <SCREEN>
-- 000:fefefeffffff00000000000000000000000000000000000000000ffffefeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddd0000dddddddddddeeeeeeefeff13333333333333333333333333333333330333203333333333333f11111111111111d1dddddddddddddddddddddddddd
-- 001:efefeffffff0000000000000000000000000000000000000000000ffffefeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddd0000dddddddddddeeeeeefeff11333333333333333333333333333333333033232033333333333311111111111111ddddddddddddddddddddddddddddd
-- 002:fefffffff0000000000000000000000000000000000000000000000ffffefeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddd0000dddddddddddeeeeeeefeff112222222222222222222222222222222022234302222222222211111111111e1ddddddddddddddddddddddddddddddd
-- 003:ffffffff000000000000000000000000000000000000000000000000ffffefeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddd0000dddddddddddeeeeeefeff111222222222222222222222222222222202234c430222222222111111111e1eddddddddddddddddddddddddddddddddd
-- 004:ffffff000000000000000000000000000000000000000000000000000ffffefeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddd0000dddddddddddeeeeeeefe11112222222222222222222222222222220222234320222222221111111e1eeddddddddddddddddddddddddddddddddddd
-- 005:ffff000000000000000000000000000000000000000000000000000000ffffefeeeeeedddddddddddddddddddddddddddddddddddddddddddddddd0000dddddddddddeeeeeefefe111222222222222222222222222222222022222322202222221111111eeeedddddddddddddddddddddddddddddddddddd
-- 006:ff000000000000000000000000000000000000000000000000000000000ffffefeeeeeeddddddddddddddddddddddddddddddddddddddddddddddd0000dddddddddddeeeeeeefe11112222222222222222222222222222202222002222022222111111eeeeeddddddddddddddddddddddddddddddddddddd
-- 007:000000000000000000000000000000000000000000000000000000000000ffffefeeeeeddddddddddddddddddddddddddddddddddddddddddddddd0000dddddddddddeeeeeefe11111222222222222222222222222222220220022002220222111111eeeeedddddddddddddddddddddddddddddddddddddd
-- 008:000000000000000000000000000000000000000000000000000000000000fffefeeeeeeedddddddddddddddddddddddddddddddddddddddddddddd0000dddddddddddeeeeeeefe111122222222222222222222222222220200222222002022111e1eeeeeeddddddddddddddddddddddddddddddddddddddd
-- 009:000000000000000000000000000000000000000cccc000000000000000000fffefeeeeeedddddddddddddddddddddddddddddddddddddddddddddd0000ddddddddddeeeeeeefe1111122222222222222222222222222220022222222220001f1efeeeeeddddddddddddddddddddddddddddddddddddddddd
-- 010:0000000000000000000000000000000000000ccddddcc0000000000000000ffffefeeeeeeddddddddddddddddddddddddddddddddddddddddddddd0000ddddddddddeeeeeeee1111112222222222222222222222222220222222222222220ffefeeeeedddddddddddddddddddddddddddddddddddddddddd
-- 011:000000000000000000000000000000000000cdde00eddc0000000000000000ffffefeeeeeddddddddddddddddddddddddddddddddddddddddddddd0000ddddddddddeeeeeeefe11111222222222222222222222222222765cccccccccc567fefeeeeeddddddddddddddddddddddddddddddddddddddddddd
-- 012:00000000000000000000000000000000000cde000000edc000000000000000fffefeeeeeeddddddddddddddddddddddddddddddddddddddddddddd0000ddddddddddeeeeeeee11111ff22222222222222222222222265cccc56722765cccc56eeeeedddddddddddddddddddddddddddddddddddddddddddd
-- 013:0000000000000000000000000000000000cde000c0000edc000000000000000fffefeeeeeedddddddddddddddddddddddddddddddddddddddddddd0000ddddddddddeeeeeee1111111f222222222222222222222225ccc56222222222f65ccc5eeeddddddddddddddddddddddddddddddddddddddddddddd
-- 014:0000000000000000000000000000000000cd000ccc0000dc000000000000000ffffefeeeeedddddddddddddddddddddddddddddddddddddddddddd0000ddddddddddeeeeeeee11111ff22222222222222222222225cc562222222222fffe65cc5edddddddddddddddddddddddddddddddddddddddddddddd
-- 015:000000000000000000000000000000000cde00ccccc000edc00000000000000fffefeeeeeedddddddddddddddddddddddddddddddddddddddddddd0000dddddddddeeeeeeee11111fff2222222222222222222222cc5222222222221ffefee5ccddddddddddddddddddddddddddddddddddddddddddddddd
-- 016:000000000000000000000000000000000cd00ccccccc000dc00000000000000ffffefeeeeedddddddddddddddddddddddddddddddddddddddddddd0000dddddddddeeeeeee1111111fff222222222222222222222c522222222222111e1eeee5cddddddddddddddddddddddddddddddddddddddddddddddd
-- 017:000000000000000000000000000000000cd000ccccc0000dc00000000000000fffefeeeeeedddddddddddddddddddddddddddddddddddddddddddd0000dddddddddeeeeeeee11111ffff2222222222222222222222222222222211111111e1dddddddddddddddddddddddddddddddddddddddddddddddddd
-- 018:000000000000000000000000000000000cde000ccc0000edc00000000000000ffffefeeeeedddddddddddddddddddddddddddddddddddddddddddd0000ddddddddeeeeeeee11111efffff2222222222222222dd222222222222111111111111d1ddddddddddddddddddddddddddddddddddddddddddddddd
-- 019:0000000000000000000000000000000000cd0000c00000dc000000000000000fffefeeeeeedddddddddddddddddddddddddddddddddddddddddddd0000ddddddddeeeeeee1111111efffff222222222222ddd2d2222222222f1111111111111111d1dddddddddddddddddddddddddddddddddddddddddddd
-- 020:0000000000000000000000000000000000cde00000000edc000000000000000ffffefeeeeedddddddddddddddddddddddddddddddddddddddddddd0000dddddddeeeeeeeee11111effffff222222222ddd222d222222222ffffe1e1111111111111111dddddddddddddddddddddddddddddddddddddddddd
-- 021:00000000000000000000000000000000000cde000000edc000000000000000ffffefeeeeeedddddddddddddddddddddddddddddddddddddddddddd0000dddddddeeeeeeee11111efefffffff22222dd222222d2222222fffffefeee1e11111111111111d1ddddddddddddddddddddddddddddddddddddddd
-- 022:000000000000000000000000000000000000cdde00eddc0000000000000000fffffefeeeeedddddddddddddddddddddddddddddddddddddddddddd0000ddddddeeeeeeee1111111efefffffff2ddd22222222d2222fffffefeeeeeeedd1d11111111111111d1dddddddddddddddddddddddddddddddddddd
-- 023:0000000000000000000000000000000000000ccddddcc0000000000000000fffffefeeeeeedddddddddddddddddddddddddddddddddddddddddddd0000ddddddeeeeeeeee11111efefeffffdddf222222222d22fffffffefeeeeeeedddddd1d11111111111111d1ddddddddddddddddddddddddddddddddd
-- 024:000000000000000000000000000000000000000cccc000000000000000000ffffefeeeeeeedddddddddddddddddddddddddddddddddddddddddddd0000dddddeeeeeeeee1111111efefefdddffffffffff1fdffffffefefeeeeeeedddddddddd1d11111111111111d1dddddddddddddddddddddddddddddd
-- 025:000000000000000000000000000000000000000000000000000000000000ffffefefeeeeeedddddddddddddddddddddddddddddddddddddddddddd0000ddddeeeeeeeeeee11111efefefefffddddfffffffdffffefefeeeeeeeeddddddddddddddd1111111111111111d1ddddddddddddddddddddddddddd
-- 026:ff000000000000000000000000000000000000000000000000000000000ffffefefeeeeeeedddddddddddddddddddddddddddddddddddddddddddd0000dddeeeeeeeeeee11111efefefefefeffffddfffffdfefefefeeeeeeeedddddddddddddddddd1d1111111111111111ddddddddddddddddddddddddd
-- 027:fffff00000000000000000000000000000000000000000000000000000ffffffefeeeeeeeddddddddddddddddddddddddddddddddddddddddddddd0000ddeeeeeeeeeee1111111efefefefefefefedefefedefefeeeeeeeeeddddddddddddddddddddddd1d11111111111111d1dddddddddddddddddddddd
-- 028:fffffff0000000000000000000000000000000000000000000000000fffffffefeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddd0000deeeeeeeeeeeee11111efefefefefefefefedefedefeeeeeeeeeedddddddddddddddddddddddddddd1d11111111111111d1ddddddddddddddddddd
-- 029:fffffffff0000000000000000000000000000000000000000000000fffffefefeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddd0000eeeeeeeeeeeee11111efefefefefefefefefdfeedeeeeeeeeeeddddddddddddddddddddddddddddddddd1d11111111111111d1dddddddddddddddd
-- 030:ffffffffffff00000000000000000000000000000000000000000ffffffefefeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddd0000eeeeeeeeeeee1111111efefefefefefeeeeedeeedeeeeeeeedddddddddddddddddddddddddddddddddddddd1d11111111111111d1ddddddddddddd
-- 031:efefefffffffff0000000000000000000000000000000000000fffffffefefeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddd0000eeeeeeeeeeeee11111eeeeeeeeeeeeeeeeeeededeeeeeeeddddddddddddddddddddddddddddddddddddddddddd1111111111111111d1dddddddddd
-- 032:fefefefefffffffff00000000000000000000000000000000ffffffffefefeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddd0000eeeeeeeeeeee11111eeeeeeeeeeeeeeeeeeeededeeeeeddddddddddddddddddddddddddddddddddddddddddddddd1d1111111111111111dddddddd
-- 033:efefefefefefffffffff000000000000000000000000000fffffffefefefeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddd0000eeeeeeeeefe1111111eeeeeeeeeeeeeeeeeeeedeeeedddddddddddddddddddddddddddddddddddddddddddddddddddd1d11111111111111d1ddddd
-- 034:eefefefefefefefffffffff00000000000000000000ffffffffffefefefeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddd0000eeeeeefefefe11111eeeeeeeeeeeeeeeeeeeeededddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1d11111111111111dddd
-- 035:eeeeeeefefefefefefffffffffffff000000ffffffffffffffefefefeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddd0000eeeeefefefe11111eeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1d111111111111ddd
-- 036:eeeeeeeeeefefefefefefffffffffffffffffffffffffffefefefeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddd0000eefefefefe1111111eeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1d1111111111dd
-- 037:eeeeeeeeeeeeeeefefefefefefffffffffffffffffefefefefefeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddd0000efefefefefe11111eeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd11111111ddd
-- 038:eeeeeeeeeeeeeeeeeefefefefefefefefefefefefefefefefeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddd0000fefefefefe11111efeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1d111dddd
-- 039:eeeeeeeeeeeeeeeeeeeeefefefefefefefefefefefefeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddd0000efefefefe1111111eeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1ddddd
-- 040:eeeeeeeeeeeeeeeeeeeeeeeeeeeefefefefefeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000fefefffefe11111efeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 041:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000effffffff11111efeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 042:deeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000ffffffff1111111efeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 043:dddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000ffffffff111111efeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 044:dddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000fffffff1111111fefeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 045:dddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000ffffffff11111fefeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 046:ddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000ffffffff11111efefeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 047:ddddddddddddddddddddddddddeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000f2222ff1111111efeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 048:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000222222ff11111efefeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 049:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd0000222222211111ffefeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 050:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111100002222222211111efefeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 051:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111110000222222221111ffefeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 052:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd11111111000022222222211ffefefeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 053:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111111110000222222222111ffefeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 054:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1111111111000022222222211ffffefeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 055:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd111111111100002222222221ffffefeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 056:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd11111111111000022222222211ffffefeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 057:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd11111111111100002222222222ffffefeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 058:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd11111111111100002222222222fffffefeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeddddddddddddddddddddddddddddd
-- 059:dddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd11111111111100002222222222ffffefeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddd
-- 060:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddd11111111111100002222222222fffffefeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddd
-- 061:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddd11111111111100002222222222ffffefeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddd
-- 062:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddd111111111111100002222222222fffffefeeeeeeeddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddd
-- 063:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddd1111111111111100002222222222ffffefeeeeeeeeddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddd
-- 064:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddd11111111111111100002222222222fffffefeeeeeeedddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddd
-- 065:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddd111111111111111100002222222222ffffefeeeeeeeeddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefefefefefefefefefeeeeeeeeeeeedddddddddddddd
-- 066:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddd1111111111111111100002222222222fffffefeeeeeeedddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefefefefefefefefefefefeeeeeeeeeeddddddddddddd
-- 067:efefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefeeeeeeeeeeeeedddddddddddddddddddddd1111111111111111100002222222222ffffefeeeeeeeeddddddddddddddddddddddddddddddddddddddeeeeeeeeefefefefefefefefefefefefefeeeeeeeeeedddddddddddd
-- 068:fefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefeeeeeeeeeeedddddddddddddddddddd11111111111111111100002222222222fffffefeeeeeeedddddddddddddddddddddddddddddddddddddeeeeeeeeefefefefffffffffffffffefefefeeeeeeeeeeddddddddddd
-- 069:efefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefeeeeeeeeeddddddddddddddddddd11111111111111111100002222222222ffffefeeeeeeeeddddddddddddddddddddddddddddddddddddeeeeeeeeefefefffffffffffffffffffffefefefeeeeeeeedddddddddd
-- 070:fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefefefefeeeeeeeeedddddddddddddddddd11111111111111111100002222222222fffffefeeeeeeedddddddddddddddddddddddddddddddddddeeeeeeefefefffffffffffffffffffffffffffefefeeeeeeedddddddddd
-- 071:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefeeeeeeeeeddddddddddddddddd11111111111111111100002222222222ffffefeeeeeeeeddddddddddddddddddddddddddddddddddeeeeeeefefefffffff222222222222222fffffffefefeeeeeeeddddddddd
-- 072:fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffefefeeeeeeeeeddddddddddddddd111111111111111111100002222222222fffffefeeeeeeedddddddddddddddddddddddddddddddddeeeeeeefefefffff222222222222222222222fffffefefeeeeeeedddddddd
-- 073:0fffffffffffffffffffffffffffffffffffffffffffffffffff00000000000fffffffffffefefeeeeeeeddddddddddddddd11111111111111111100002222222222ffffefeeeeeeeeddddddddddddddddddddddddddddddddeeeeeeefeffffff2222222222222222222222222ffffffefeeeeeeeddddddd
-- 074:000000000000000000000000000000000000000000000000000000000000000000000ffffffefefeeeeeeedddddddddddddd11111111111111111100002222222222fffffefeeeeeeedddddddddddddddddddddddddddddddeeeeeeefefffff22222222222222222222222222222fffffefeeeeeeedddddd
-- 075:000000000000000000000000000000000000000000000000000000000000000000000000ffffffefeeeeeeeddddddddddddd11111111111111111100002222222222ffffefeeeeeeeeddddddddddddddddddddddddddddddeeeeeeefeffff22222222222222222222222222222222fffffefeeeeeedddddd
-- 076:00000000000000000000000000000000000000000000000000000000000000000000000000fffffefeeeeeeeeddddddddddd11111111111111111100002222222222fffffefeeeeeeedddddddddddddddddddddddddddddeeeeeeefeffff2222222222222222222222222222222222fffffefeeeeeeddddd
-- 077:0000000000000000000000000000000000000000000000000000000000000000000000000000ffffefeeeeeeeeddddddddddd1111111111111111100002222222222ffffefeeeeeeeeddddddddddddddddddddddddddddeeeeeeefefff2222222222222222222222222222222222222fffffefeeeeeedddd
-- 078:00000000000000000000000000000000000000000000000000000000000000000000000000000ffffefeeeeeeeedddddddddd1111111111111111100002222222222fffffefeeeeeeedddddddddddddddddddddddddddeeeeeeefefff222222222222222222222222222222222222222fffefeeeeeeedddd
-- 079:0000000000000000000000000000000000000000000000000000000000000000000000000000000fffefefeeeeeeeddddddddd111111111111111100002222222222ffffefeeeeeeeeddddddddddddddddddddddddddeeeeeeefefff22222222222222222222222222222222222222222fffefeeeeeeeddd
-- 080:000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffefeeeeeeedddddddd111111111111111100002222222222fffffefeeeeeeedddddddddddddddddddddddddeeeeeeefefff2222222222222222222222222222222222222222222fffefeeeeeeddd
-- 081:0000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffefeeeeeeeedddddd111111111111111100002222222222ffffefeeeeeeeeddddddddddddddddddddddddeeeeeeefefff222222222222222222222222222222222222222222222fffefeeeeeedd
-- 082:000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffefeeeeeeeeddddd111111111111111100002222222222fffffefeeeeeeeddddddddddddddddddddddddeeeeeefefff2222222222222222222222222222222222222222222222ffffeeeeeeedd
-- 083:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffefeeeeeeeeedd1111111111111111100002222222222ffffefeeeeeeeedddddddddddddddddddddddeeeeeefefff222222222222222222222222222222222222222222222222ffefeeeeeedd
-- 084:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffefeeeeeeee1111111111111111100002222222222fffffefeeeeeeeddddddddddddddddddddddeeeeeefefff2222222222222222222222222222222222222222222222222fffefeeeeeed
-- 085:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffefeeeeeee1111111111111111100002222222222ffffefeeeeeeeedddddddddddddddddddddeeeeeefefff222222222222222222222222222222222222222222222222222fffefeeeeed
-- 086:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffefeeeeee1111111111111111100002222222222fffffefeeeeeeeddddddddddddddddddddeeeeeefefff2222222222222222222222222222222222222222222222222222ffefeeeeeed
-- 087:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffefeeee11111111111111111100002222222222ffffefeeeeeeeeddddddddddddddddddddeeeeeeeffff2222222222222222222222222222222222222222222222222222fffefeeeeed
-- 088:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffefee1111111111111111100002222222222fffffefeeeeeeedddddddddddddddddddeeeeeeefeff222222222222222222222222222222222222222222222222222222fffeeeeeed
-- 089:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffef11111111111111111100002222222222ffffefeeeeeeeeddddddddddddddddddeeeeeeefeff2222222222222222222222222222222222222222222222222222222ffefeeeeed
-- 090:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffe11111111111111111100002222222222fffffefeeeeeeeddddddddddddddddddeeeeeefefff2222222222222222222222222222222222222222222222222222222fffeeeeeed
-- 091:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff111111111111111111100002222222222ffffefeeeeeeeedddddddddddddddddeeeeeefefff22222222222222222222222222222222222222222222222222222222ffefeeeeed
-- 092:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f111111111111111111100002222222222fffffefeeeeeeeeddddddddddddddddeeeeeeeffff22222222222222222222222222222222222222222222222222222222fffeeeeeed
-- 093:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111111111111100002222222222ffffefeeeeeeeeedddddddddddddddeeeeeeefeff222222222222222222222222222222222222222222222222222222222ffefeeeeed
-- 094:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111111100002222222222fffffefeeeeeeeedddddddddddddddeeeeeefefff222222222222222222222222222222222222222222222222222222222fffeeeeeed
-- 095:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000111111111111111000022222222222fffefeeeeeeeeeddddddddddddddeeeeeeeefff2222222222222222222222222222222222222222222222222222222222ffefeeeeed
-- 096:0000000000000000000000000000000000000000000000000000000000d00000000000000000000000000000000000000000000011111111111111000022222222222ffffefeeeeeeeeddddddddddddddeeeeeeefeff222222222222222222222222222222222222222222222222222222222ffefeeeeedd
-- 097:0000000000000000000000000000000000000000000000000000000000dd0000000000000000000000000000000000000000000001111111111111000022222222222fffefeeeeeeeeeddddddddddddddeeeeeefefff222222222222222222222222222222222222222222222222222222222fffeeeeeedd
-- 098:0000000000000000000000000000000000000000000000000000000000dd0000000000000000000000000000000000000000000000011111111111000022222222222ffffefeeeeeeeedddddddddddddeeeeeeeefff2222222222222222222222222222222222222222222222222222222222ffefeeeeedd
-- 099:000000000000000000000000000000000000000000000000000000000d00d000000000000000000000000000000000000000000000001111111111000022222222222fffefeeeeeeeeedddddddddddddeeeeeeefeff222222222222222222222222222222222222222222222222222222222ffefeeeeeddd
-- 100:000000000000000000000000000000000000000000000000000000000d000d00000000000000000000000000000000000000000000000111111111000022222222222ffffefeeeeeeeedddddddddddddeeeeeefefff222222222222222222222222222222222222222222222222222222222fffeeeeeeddd
-- 101:000000000000000000000000000000000000000000000000000000000d000d00000000000000000000000000000000000000000000000011111111000022222222222fffefeeeeeeeeeddddddddddddeeeeeeeeffff222222222222222222222222222222222222222222222222222222222ffefeeeedddd
-- 102:000000000000000000000000000000000000000000000000000000000d0000d0000000000000000000000000000000000000000000000001111111000022222222222ffffefeeeeeeeeddddddddddddeeeeeeefeff222222222222222222222222222222222222222222222222222222222ffefeeeeedddd
-- 103:00000000000000000000000000000000000000000000000000000000d000000d000000000000000000000000000000000000000000000000111ff1000022222222222fffefeeeeeeeeeddddddddddddeeeeeeeefff222222222222222222222222222222222222222222222222222222222fffeeeeeddddd
-- 104:00000000000000000000000000000000000000000000000000000000d000000d0000000000000000000000000000000000000000000000000ffffe000022222222222ffffefeeeeeeeeddddddddddddeeeeeeefeff22222222222222222222222222222222222222222222222222222222fffeeeeedddddd
-- 105:00000000000000000000000000000000000000000000000000000000d0000000d0000000000000000000000000000000000000000000000000ffff000022222222222fffefeeeeeeeeeddddddddddddeeeeeeeefff2222222222222222222222222222222222222222222222222222222fffeeeeeedddddd
-- 106:00000000000000000000000000000000000000000000000000000000d00000000d0000000000000000000000000000000000000000000000000fff000022222222222ffffefeeeeeeeeddddddddddddeeeeeeefeff2222222222222222222222222222222222222222222222222222222ffefeeeeddddddd
-- 107:0000000000000000000000000000000000000000000000000000000d000000000d0000000000000000000000000000000000000000000000000fff000022222222222fffefeeeeeeeeeddddddddddddeeeeeeeefff222222222222222222222222222222222222222222222222222222ffefeeeedddddddd
-- 108:0000000000000000000000fffffffff000000000000000000000000d0000dd0000d0000000000000000000000000000000000000000000000000ff000022222222222ffffefeeeeeeeeddddddddddddeeeeeeefeff22222222222222222222222222222222222222222222222222222ffefeeeeddddddddd
-- 109:0000000000000000000fffffffffffffff000000000000000000000d000d00ddd00d000000000000000000000000000000000000000000000000ff000022222222222fffefeeeeeeeeeddddddddddddeeeeeeeefff2222222222222222222222222222222222222222222222222222ffefeeeeeddddddddd
-- 110:0000000000000000fffffffefefefefffffff000000000000000000d0dd000000ddd0000000000000000000000000000000000000000000000000f000022222222222ffffefeeeeeeeeddddddddddddeeeeeeefefff22222222222222222222222222222222222222222222222222ffffeeeeedddddddddd
-- 111:00000000000000ffffffefefefefefefeffffff000000000000000d0d0000000000dd000000000000000000000000000000000000000000000000f000022222222222fffefeeeeeeeeeddddddddddddeeeeeeeeffff22222222222222222222222222222222222222222222222222fffeeeeeddddddddddd
-- 112:0000000000000ffffefefeeeeeeeeeeefefeffff00000000000000dd00000000000000000000000000000000000000000000000000000000000000000022222222222ffffefeeeeeeeeddddddddddddeeeeeeefefff2222222222222222222222222222222222222222222222222fffeeeeedddddddddddd
-- 113:00000000000fffefefeeeeeeeeeeeeeeeeefefefff000000000000d000000000000000000000000000000000000000000000000000000000000000000022222222222fffefeeeeeeeeeddddddddddddeeeeeeeefeff222222222222222222222222222222222222222222222222fffeeeeeddddddddddddd
-- 114:0000000000fffefeeeeeeeeeeeeeeeeeeeeeeefeff765cccccccccc567000000000000000000000000000000000000000000000000000000000000000022222222222ffffefeeeeeeeeddddddddddddeeeeeeefefff22222222222222222222222222222222222222222222222fffeeeeedddddddddddddd
-- 115:00000000ffffefeeeeeeeeeeeeeeeeeeeeeeeeef65cccc56700765cccc560000000000000000000000000000000000000000000000000000000000000022222222222fffefeeeeeeeeeddddddddddddeeeeeeeefefff222222222222222222222222222222222222222222222fffeeeeeedddddddddddddd
-- 116:0000000ffffefeeeeeeedddddddddddddeeeeee5ccc56f00000000065ccc5000000000000000000000000000000000000000000000000000000000000022222222222ffffefeeeeeeeeddddddddddddeeeeeeeeeffff22222222222222222222222222222222222222222222fffeeeeeeddddddddddddddd
-- 117:000000ffefeeeeeeeedddddddddddddddddeee5cc56feff000000000065cc500000000000000000000000000000000000000000000000000000000000022222222222fffefeeeeeeeeedddddddddddddeeeeeeefefff2222222222222222222222222222222222222222222fffeeeeeedddddddddddddddd
-- 118:0000fffefeeeeeeedddddddddddddddddddddecc5eeefefff00000000005cc00000000000000000000000000000000000000000000000000000000000022222222222ffffefeeeeeeeedddddddddddddeeeeeeeefefff2222222222222222222222222222222222222222ffffeeeeeeddddddddddddddddd
-- 119:000fffefeeeeeeddddddddddddddddddddddddc5eeeeefefff00000000005c00000000000000000000000000000000000000000000000000000000000022222222222fffefeeeeeeeeedddddddddddddeeeeeeefeffff222222222222222222222222222222222222222ffffeeeeeedddddddddddddddddd
-- 120:00fffefeeeeeedddddddddddddddddddddddddddeeeeeefefff0000000000000000000000000000000000000000000000000000000000000000000000022222222222ffffefeeeeeeeedddddddddddddeeeeeeeefefff22222222222222222222222222222222222222ffffeeeeeeddddddddddddddddddd
-- 121:0fffefeeeeedddddddddddddddddddddddddddddddeeeeefefff000000000000000000000000000000000000000000000000000000000000000000000022222222222fffefeeeeeeeeeddddddddddddddeeeeeeeefefff222222222222222222222222222222222222ffffeeeeeedddddddddddddddddddd
-- 122:fffefeeeeedddddddddddddddddddddddddddddddddeeeeefeffff0000000000000000000000000000000000000000000000000000000000000000000022222222222ffffefeeeeeeeeddddddddddddddeeeeeeefeffff22222222222222222222222222222222222ffffeeeeeeddddddddddddddddddddd
-- 123:ffefeeeeedddddddddddddddddddddddddddddddddddeeeeefeffff000000000000000000000000000000000000000000000000000000000000000000022222222222fffefeeeeeeeeeddddddddddddddeeeeeeeefeffff22222222222222222222222222222222fffffeeeeeedddddddddddddddddddddd
-- 124:fefeeeeedddddddddddddddddddddddddddddddddddddeeeeefeffff00000000000000000000000000000000000000000000000000000000000000000022222222222ffffefeeeeeeeedddddddddddddddeeeeeeeefeffff222222222222222222222222222222fffffeeeeeeedddddddddddddddddddddd
-- 125:efeeeeedddddddddddddddddddddddddddddddddddddddeeeeefeffff0000000000000000000000000000000000000000000000000000000000000000022222222222fffefeeeeeeeeedddddddddddddddeeeeeeeeefefff22222222222222222222222222222fffefeeeeeeeddddddddddddddddddddddd
-- 126:feeeeedddddddddddddddddddddddddddddddddddddddddeeeeefefffff00000000000000000000000000000000000000000000000000000000000000022222222222ffffefeeeeeeeedddddddddddddddeeeeeeeefefffff222222222222222222222222222fffefeeeeeeedddddddddddddddddddddddd
-- 127:eeeeedddddddddddddddddddddddddddddddddddddddddddeeeeefefffff0000000000000000000000000000000000000000000000000000000000000022222222222fffefeeeeeeeeeddddddddddddddddeeeeeeeefefffff2222222222222222222222222fffefeeeeeeeddddddddddddddddddddddddd
-- 128:eeeedddddddddddddddddddddddddddddddddddddddddddddeeeeefefefff000000000000000000000000000000000000000000000000000000000000022222222222ffffefeeeeeeeeddddddddddddddddeeeeeeeeefeffff222222222222222222222222fffefeeeeeeedddddddddddddddddddddddddd
-- 129:eeedddddddddddddddddddddddddddddddddddddddddddddddeeeeefefefff00000000000000000000000000000000000000000000000000000000000022222222222fffefeeeeeeeeeddddddddddddddddeeeeeeeeeefeffff2222222222222222222222fffefeeeeeeeedddddddddddddddddddddddddd
-- 130:eedddddddddddddddddddddddddddddddddddddddddddddddddeeeeefefefff0000000000000000000000000000000000000000000000000000000000022222222222ffffefeeeeeeeedddddddddddddddddeeeeeeeefefeffff2222222222222222222ffffefeeeeeeeeddddddddddddddddddddddddddd
-- 131:edddddddddddddddddddddddddddddddddddddddddddddddddddeeeeefefefff000000000000000000000000000000000000000000000000000000000022222222222fffefeeeeeeeeedddddddddddddddddeeeeeeeeefefeffff22222222222222222ffffefeeeeeeeedddddddddddddddddddddddddddd
-- 132:edddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeefefefff00000000000000000000000000000000000000000000000000000000022222222222ffffefeeeeeeeeddddddddddddddddddeeeeeeeeefefffffff2222222222222fffffefeeeeeeeeddddddddddddddddddddddddddddd
-- 133:dddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeefefefff0000000000000000000000000000000000000000000000000000000022222222222fffefeeeeeeeeeddddddddddddddddddeeeeeeeeeefefffffff2222222222ffffffefeeeeeeeedddddddddddddddddddddddddddddd
-- 134:ddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeefefefff444444444444444444444444444444444444444444444444444000022222222222ffffefeeeeeeeedddddddddddddddddddeeeeeeeeeefefffffffff2222ffffffffefeeeeeeeeddddddddddddddddddddddddddddddd
-- 135:dddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeefefeff444444444444444444444444444444444444444444444444444000022222222222fffefeeeeeeeeedddddddddddddddddddeeeeeeeeefefefffffffffffffffffffefeeeeeeeedddddddddddddddddddddddddddddddd
-- </SCREEN>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

