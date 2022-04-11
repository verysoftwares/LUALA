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
				rem(ships,j); rem(cams,j); rem(old_cams,j) 
				
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
		if btnp((s.id-1)*8+4+i-1) and not s.onbase then 
				if s[fmt('shot%d',i)] then 
						if s[fmt('shot%d',i)].nrj>0 then
						local id= inventory[j][s[fmt('shot%d',i)].invi].id
						if id==32 then ins(shots,{x=s.x-3,y=s.y-3,id=id,dx=cos(s.a+pi)*3,dy=sin(s.a+pi)*3,owner=s}) end
						if id==50 then ins(shots,{x=s.x-3,y=s.y-3,id=id,dx=cos(s.a+pi)*3,dy=sin(s.a+pi)*3,owner=s}) end
						if id==49 then ins(static,{x=s.x-3,y=s.y-3,id=id,dx=0,dy=0,owner=s,iframes=90}) end
						s[fmt('shot%d',i)].nrj=s[fmt('shot%d',i)].nrj-1
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
				s.oldx=s.x; s.oldy=s.y
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
				if math.floor(s.oldy)~=math.floor(s.y) or math.floor(s.oldx)~=math.floor(s.x) then
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
				::endloop::
		end
		
		for i=#static,1,-1 do
				local st=static[i]
				if st.oldpos then
						clear_sprite(st)
				end
		end
		for i=#static,1,-1 do
				local st=static[i]
				for lx=0,7 do for ly=0,7 do
				if sprpix(st.id,lx,ly)~=0 then
						local p= pixels[posstr(st.x+lx,st.y+ly+(t*0.08)*2.5)]
						if st.iframes==0 and p and not (p==2 or p==1) then 
						clear_sprite(st)
						rem(static,i)
						explode(st)
						goto blowup
						end
				end
				end end
				
				for j,s in ipairs(ships) do
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				spr(st.id,cams[j].ax+st.x-cams[j].x,cams[j].ay+st.y-cams[j].y+sin(t*0.08)*2.5,0,1,0,0,1,1)
				end

				st.oldpos={x=st.x,y=st.y+sin(t*0.08)*2.5}

				for j,s in ipairs(ships) do
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				
				if st.iframes==0 then
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

				if st.iframes>0 then st.iframes=st.iframes-1 end
				
				::blowup::
				clip()
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
				else rem(shots,i) end
		
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
				for j,s in ipairs(ships) do
				if sh.owner~=s then
				local points={{x=s.x-cos(s.a)*8,y=s.y-sin(s.a)*8},
	         								{x=s.x-cos(s.a-2*pi/3-0.3)*11,y=s.y-sin(s.a-2*pi/3-0.3)*11},
																		{x=s.x+cos(s.a)*4,y=s.y+4*sin(s.a)},
																		{x=s.x-cos(s.a+2*pi/3+0.3)*11,y=s.y-sin(s.a+2*pi/3+0.3)*11}}
				if PointWithinShape(points,sh.x+3,sh.y+3) then
						for j2,s2 in ipairs(ships) do
								clip(cams[j2].ax,cams[j2].ay,cams[j2].aw,cams[j2].ah)
								for lx=0,7 do for ly=0,7 do
										if sprpix(32,lx,ly)~=0 then
												local p=pixels[posstr(sh.x+lx,sh.y+ly)]
												if p then pix(cams[j2].ax-cams[j2].x+sh.x+lx,cams[j2].ay-cams[j2].y+sh.y+ly,p)
												else pix(cams[j2].ax-cams[j2].x+sh.x+lx,cams[j2].ay-cams[j2].y+sh.y+ly,0) end
										end
								end end
						end
						clip()
						dmg(s,3)
						rem(shots,i)
						break
				end
				end
				end
		end

		for i=#explosions,1,-1 do
				local exp=explosions[i]
				for j,s in ipairs(ships) do
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				for x=exp.x-(exp.r+1),exp.x+(exp.r+1) do for y=exp.y-(exp.r+1),exp.y+(exp.r+1)+1 do
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
		for lx=0,7 do for ly=0,7 do
				if sprpix(sh.id,lx,ly)~=0 then
						local px,py=sh.oldpos.x,sh.oldpos.y
						if px<0 then px=math.floor(px+1) end
						if py<0 then py=math.floor(py+1) end
						local p=pixels[posstr(px+lx,py+ly)]

						for j,s in ipairs(ships) do
						clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
						if not p then
								pix(cams[j].ax-cams[j].x+px+lx,cams[j].ay-cams[j].y+py+ly,0)
						else 
						if p==2 then p=trc end
						pix(cams[j].ax-cams[j].x+px+lx,cams[j].ay-cams[j].y+py+ly,p) end
						end
						clip()
				end
		end end
end

inventory={}

function pick_up(j,pwrid,silent)
		if not inventory[j] then inventory[j]={} end
		local full=false
		for i=1,9 do
				if not inventory[j][i] then
						inventory[j][i]={id=pwrid}
						if i==9 then full=true end
						break
				end
				if i==9 then return end
		end
		if not silent then alert(j,fmt('Picked up %s.',idtag(pwrid))) end
		if full then alert(j,'Inventory is now full.') end
end

idtags={
		[32]={'Blaster',nrj=40},
		[33]={'Drone',nrj=4},
		[34]={'Missile',nrj=14},
		[49]={'Mine',nrj=8},
		[50]={'Plasma',nrj=14},
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
		if s.flash then c=12; s.flash=s.flash-1; if s.flash==0 then s.flash=nil end end
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

				rect(cam.ax,cam.ay,cam.aw,8,c)
				local tw=print(alerts[j].msgs[1],0,-6,c2,false,1,true)
				print(alerts[j].msgs[1],cam.ax+cam.aw/2-tw/2,cam.ay+1,c2,false,1,true)

				alerts[j].t=alerts[j].t-1
				if alerts[j].t==0 then rem(alerts[j].msgs,1); if #alerts[j].msgs==0 then alerts[j]=nil else alerts[j].t=160 end end
		end
		
		if s.onbase then
				local cx,cy=cam.aw/2,cam.ah/2
				inventory[j].i=inventory[j].i or 1

				local function actuallen(inv)
						-- for inventories that contain holes
						for i=9-1,0,-1 do
								if inv[i] then return i end
						end
						return 0
				end

				local scrap=false				
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
										scrap=true; keymap[j][(s.id-1)*8+4]=2
										else inventory[j].i=inventory[j].i-1; if inventory[j].i<1 then inventory[j].i=actuallen(inventory[j]) end 
										end
										end
										if i==3 then inventory[j].i=inventory[j].i+1; if inventory[j].i>actuallen(inventory[j]) then inventory[j].i=1 end end
										if i==4 then
										if btn((s.id-1)*8+2) then
										scrap=true; keymap[j][(s.id-1)*8+2]=2
										else if inventory[j][inventory[j].i] then local oldshot1=s.shot1; if oldshot1 then inventory[j][oldshot1.invi].nrj=oldshot1.nrj end; s.shot1={invi=inventory[j].i,nrj=inventory[j][inventory[j].i].nrj or idtags[inventory[j][inventory[j].i].id].nrj}; if s.shot2 and s.shot2.invi==inventory[j].i then s.shot2=nil end end 
										end
										end
										if i==5 then if inventory[j][inventory[j].i] then local oldshot2=s.shot2; if oldshot2 then inventory[j][oldshot2.invi].nrj=oldshot2.nrj end; s.shot2={invi=inventory[j].i,nrj=inventory[j][inventory[j].i].nrj or idtags[inventory[j][inventory[j].i].id].nrj}; if s.shot1 and s.shot1.invi==inventory[j].i then s.shot1=nil end end 
										end
								end
								if keymap[j] then keymap[j][(s.id-1)+i]=nil end
						end
				end
				if scrap then inventory[j][inventory[j].i]=nil; if s.shot1 and s.shot1.invi==inventory[j].i then s.shot1=nil end; if s.shot2 and s.shot2.invi==inventory[j].i then s.shot2=nil end end
				
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
						if s.shot1 and i+1==s.shot1.invi then
								print('S1',cam.ax+cx-6*9+i*12+1,cam.ay+cy-6+12+2,12)
						end
						if s.shot2 and i+1==s.shot2.invi then
								print('S2',cam.ax+cx-6*9+i*12+1,cam.ay+cy-6+12+2,12)
						end
				end
				if not s.moved and not (s.shot1 or s.shot2) then
						local tw= print('Select weapon.',0,-6,12,false,1,true)
						print('Select weapon.',cam.ax+cx-tw/2,cam.ay+cy-6-8,12,false,1,true)
				end
				if not s.moved and (s.shot1 or s.shot2) then
						local tw= print('Move up to leave base.',0,-6,12,false,1,true)
						print('Move up to leave base.',cam.ax+cx-tw/2,cam.ay+cy-6-8,12,false,1,true)
				end
		end
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
		pick_up(j,32,true) -- starting weapon: Blaster
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
		if type==2 then id=33 end
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
		print('Version 1c',2,136-8,13,false,1,true)

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

function alert(j,msg)
		if alerts[j] then if alerts[j].msgs[#alerts[j].msgs]~=msg then ins(alerts[j].msgs,msg) end
		else	alerts[j]={msgs={msg},t=160} end
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
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 032:000c000000ccc0000ccccc00ccccccc00ccccc0000ccc000000c000000000000
-- 033:000000000001100000211200d322223dd332233d013333100001100000000000
-- 034:0006700000055000000550000075570006566560056556500570075005000050
-- 035:0002000000131000002320000024200000242000002320000013100000020000
-- 036:000000cc0000ccdd000cdde000cde0000cde00000cd00000cde00000cd000000
-- 037:cc000000ddcc00000eddc000000edc000000edc000000dc000000edc000000dc
-- 049:0000000001011010001231000122231001111110001231000101101000000000
-- 050:000200000023200002343200234c432002343200002320000002000000000000
-- 051:2222222222222222222222222222222222222222222222222222222222222222
-- 052:cd000000cde000000cd000000cde000000cde000000cdde00000ccdd000000cc
-- 053:000000dc00000edc00000dc00000edc0000edc000eddc000ddcc0000cc000000
-- 064:00000000000000000000765c0065cccc05ccc5605cc56000cc500000c5000000
-- 065:0000000000000000cccccccc5670076500000000000000000000000000000000
-- 066:0000000000000000c5670000cccc5600065ccc5000065cc5000005cc0000005c
-- 067:2222222222222222222222222222222222222222222222222222222222222222
-- 068:0cccc00ccdddd00dcd000000cd000000cd0000000000000000000000cd000000
-- 069:ccc00000dddc000000dc000000dc000000dc0000000000000000000000dc0000
-- 080:2222222222222222222222222222222222222222222222222222222222222222
-- 081:2222222222222222222222222222222222222222222222222222222222222222
-- 082:2222222222222222222222222222222222222222222222222222222222222222
-- 083:2222222222222222222222222222222222222222222222222222222222222222
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
-- 000:dddddddddddddddddddddeeeeeeefefefffffffffffffffffffefeeeeeeeeddddddddddddddddddddddddddddddddddddddddddeeeeeeeeefefefe00000000000ffefeeeeeedddddddddddddddddddddddddddddddddeeeeeefeff0000000000000000000000000000000000000000000000000000000ffe
-- 001:ddddddddddddddddddddddeeeeeeefefefffffffffffffffffefeeeeeeeedddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefefef00000000000fffeeeeeedddddddddddddddddddddddddddddddddeeeeeefeff00000000000000000000000000000000000000000000000000000000fff
-- 002:dddddddddddddddddddddddeeeeeeeeefefefffffffffffefefeeeeeeeedddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefeffff0000000000fffeeeeeeeddddddddddddddddddddddddddddddddeeeeeefeff000000000000000000000000000000000000000000000000000000000ffe
-- 003:ddddddddddddddddddddddddeeeeeeeeefefefffffffffefefeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddeeeeeeefefefffff000000000fffeeeeeeedddddddddddddddddddddddddddddddeeeeeeefeff0000000000000000000000000000000000000000000000000000000000fff
-- 004:ddddddddddddddddddddddddeeeeeeeeeefefefefefefefefeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddeeeeeeefefeffffff00000000fffefeeeeedddddddddddddddddddddddddddddddeeeeeeefeff00000000000000000000000000000000000000000000000000000000000ffe
-- 005:dddddddddddddddddddddddddeeeeeeeeeefefefefefefefeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddeeeeeefefefffffff0000000fffefeeeeedddddddddddddddddddddddddddddddeeeeeeefeff000000000000000000000000000000000000000000000000000000000000fff
-- 006:ddddddddddddddddddddddddddeeeeeeeeeefefefefefefeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddeeeeeeeefeffffff00000000fffefeeeeeedddddddddddddddddddddddddddddeeeeeeeefefff000000000000000000000000000000000000000000000000000000000000ffe
-- 007:dddddddddddddddddddddddddddeeeeeeeeeefefefefefeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddeeeeeeefeffffff00000000fffefeeeeeedddddddddddddddddddddddddddddeeeeeeeefefff000000000000000000000000000000000000000000000000000000000000ffff
-- 008:dddddddddddddddddddddddddddeeeeeeeeeeefefefefeeeee1eeeeeddddddddddddddddddddddddddddddddddddddddddddeeeeeefeffffff00000000fffefeeeeeedddddddddddddddddddddddddddddeeeeeeeefefff0000000000000000000000000000000000000000000000000000000000000fffe
-- 009:ddddddddddddddddddddddddddddeeeeeeeeeeeeefefeeeee111eeedddddddddddddddddddddddddddddddddddddddddddddeeeeefefeffff000000000ffefeeeeeedddddddddddddddddddddddddddddeeeeeeeefefff00000000000000000000000000000000000000000000000000000000000000ffef
-- 010:ddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeee11111eeddddddddddddddddddddddddddddddddddddddddddddeeeeeeefefffff000000000fefeeeeeedddddddddddddddddddddddddddddeeeeeeeefefff00000000000000000000000000000000000000000000000000000000000000ffffe
-- 011:ddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeee1111111eddddddddddddddddddddddddddddddddddddddddddddeeeeeefeffffff000000000efeeeeeedddddddddddddddddddddddddddddeeeeeeeefefff000000000000000000000000000000000000000000000000000000000000000fffef
-- 012:ddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeee11111edddddddddddddddddddddddddddddddddddddddddddddeeeeeeefeffff0000000000feeeeeedddddddddddddddddddddddddddddeeeeeeeefeffff00000000000000000000000000000000000000000000000000000000000000fffefe
-- 013:dddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeee11111edddddddddddddddddddddddddddddddddddddddddddddeeeeeefefffff0000000000eeeeeedddddddddddddddddddddddddddddeeeeeeeefeffff000000000000000000000000000000000000000000000000000000000000000ffffee
-- 014:dddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeee1111111dddddddddddddddddddddddddddddddddddddddddddddeeeeeeefeffff0000000000eeeeeddddddddddddddddddddddddddddddeeeeeeefefeff000000000000000000000000000000000000000000000000000000000000000ffffeee
-- 015:ddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeee11111edddddddddddddddddddddddddddddddddddddddddddddeeeeeefeffffff000000000eeeeddddddddddddddddddddddddddddddeeeeeeeeefefff000000000000000000000000000000000000000000000000000000000000000fffefee
-- 016:ddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeee11111edddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefffff000000000eeedddddddddddddddddddddddddddddddeeeeeeeefefff000000000000000000000000000000000000000000000000000000000000000fffefeee
-- 017:ddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeee1111111dddddddddddddddddddddddddddddddddddddddddddeeeeeeefeffffff000000000eedddddddddddddddddddddddddddddddeeeeeeeefeffff00000000000000000000000000000000000000000000000000000000000000fffefeeee
-- 018:dddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeee11111edddddddddddddddddddddddddddddddddddddddddddeeeeeeeefeffffff00000000eddddddddddddddddddddddddddddddddeeeeeeefeffff00000000000000000000000000000000000000000000000000000000000000fffefeeeee
-- 019:dddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeee11111eddddddddddddddddddddddddddddddddddddddddddeeeeeeefefeffffff0000000dddddddddddddddddddddddddddddddddeeeeeeeefefff0000000000000000000000000000000000000000000000000000000000000fffefeeeeee
-- 020:ddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeee111c111edddddddddddddddddddddddddddddddddddddddddeeeeeeeefefeffffff000000ddddddddddddddddddddddddddddddddeeeeeeeefeffff000000000000000000000000000000000000000000000000000000000000fffffeeeeeee
-- 021:dddddddddddddddddddddddddeeeeeeeeeeeeeefefefeeeeee1ccc1eedddddddddddddddddddddddddddddddddddddddddeeeeeeeeefefffffffff0000ddddddddddddddddddddddddddddddddeeeeeeefeffff000000000000000000000000000000000000000000000000000000000000fffffefeeeeed
-- 022:ddddddddddddddddddddddddeeeeeeeeeeeeeefefefefeeeeeccccceeeddddddddddddddddddddddddddddddddddddddddeeeeeeeefefeffffffff0000ddddddddddddddddddddddddddddddddeeeeeeeefefff00000000000000000000000000000000000000000000000000000000000fffffefeeeeedd
-- 023:dddddddddddddddddddddddeeeeeeeeeeeeeefefefefefefeccccccceeedddddddddddddddddddddddddddddddddddddddeeeeeeeeefefefffffff0000ddddddddddddddddddddddddddddddddeeeeeeefeffff0000000000000000000000000000000000000000000000000000000000fffffefeeeeeddd
-- 024:ddddddddddddddddddddddeeeeeeeeeeeefefefefefefefefeccccceeeeeddddddddddddddddddddddddddddddddddddddeeeeeeeeeefefeffffff0000ddddddddddddddddddddddddddddddddeeeeeeeefefff0000000000000000000000000000000000000000000000000000000000ffffefeeeeeeddd
-- 025:ddddddddddddddddddddeeeeeeeeeeeeefefefefefefefefefeccc11eeeeeeddddddddddddddddddddddddddddddddddddeeeeeeeeeeefefefefff0000ddddddddddddddddddddddddddddddddeeeeeeefeffff0000000000000000000000000000000d0000000000000000000000000ffffefeeeeeedddd
-- 026:ddddddddddddddddddeeeeeeeeeeeeeefefefefefefefefefe11c1111eeeeeedddddddddddddddddddddddddddddddddddeeeeeeeeeeeefefefefe0000ddddddddddddddddddddddddddddddddeeeeeeeefefff0000000000000000000000000000000d000000000000000000000000ffffefeeeeeeddddd
-- 027:ddddddddddddddddeeeeeeeeeeeeeeefefefefefefefefefefe11111eeeeeeeeeddddddddddddddddddddddddddddddddeeeeeeeeeeeeeefefefef0000ddddddddddddddddddddddddddddddddeeeeeeefeffff000000000000000000000000000000d0d0000000000000000000000ffffefeeeeeedddddd
-- 028:eeedddddddddeeeeeeeeeeeeeeeefefefefefefffffffffefef11111eeeeeeeeeeeddddddddddddddddddddddddddddddeeeeeeeeeeeeeeefefefe0000ddddddddddddddddddddddddddddddddeeeeeefefefff000000000000000000000000000000d0d000000000000000000000ffffefeeeeeeddddddd
-- 029:eeeeeeeeeeeeeeeeeeeeeeeeeeefefefefefffffffffffffef1111111eeeeeeeeeeeeddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeefef0000ddddddddddddddddddddddddddddddddeeeeeeefeffff00000000000000000000000000000d000d0000000000000000000ffffefeeeeeeeddddddd
-- 030:eeeeeeeeeeeeeeeeeeeeeeeefefefefefffffffffffffffffff11111feeeeeeeeeeeeeeedddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeee0000ddddddddddddddddddddddddddddddddeeeeeeeefefff00000000000000000000000000000d000d000000000000000000ffffefeeeeeeedddddddd
-- 031:eeeeeeeeeeeeeeeeeeeeeeefefefefefffffffffffffffffffff11111fefeeeeeeeeeeeeeeeddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeee0000ddddddddddddddddddddddddddddddddeeeeeeefeffff0000000000000000000000000000d00000d0000000000000000ffffefeeeeeeeddddddddd
-- 032:eeeeeeeeeeeeeeeeeeeefefefefefffffffffffffffffffffff1111111fefeeeeeeeeeeeeeeeeeeeddddddddddddddddeeeeeeeeeeeeeeeeeeeeee0000ddddddddddddddddddddddddddddddddeeeeeeeefefff0000000000000000000000000000d00000d0000000000000000fffefeeeeeeedddddddddd
-- 033:eeeeeeeeeeeeeeeeefefefefefefffffffffffffffffffffffff11111fefefefeeeeeeeeeeeeeeeeeeeeeddddddddddeeeeeeeeeeeeeeeeeeeeeee0000ddddddddddddddddddddddddddddddddeeeeeeefeffff000000000000000000000000000d000000d000000000000000fffefeeeeeeeddddddddddd
-- 034:feeeeeeeeeeefefefefefefeffffffffffff000000000000fffff11111fefefefeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000ddddddddddddddddddddddddddddddddeeeeeeeefefff000000000000000000000000000d0000000d0000000000000fffefeeeeeeddddddddddddd
-- 035:efefefefefefefefefefeffffffffffff00000000000000000ff1111111fefefefefeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000ddddddddddddddddddddddddddddddddeeeeeeefeffff00000000000000000000000000d00000000d000000000000fffefeeeeeedddddddddddddd
-- 036:fefefefefefefefefeffffffffffff0000000000000000000000011111fffffefefefefeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000dddddddddddddddddddddddddddddddddeeeeeeefeffff0000000000000000000000000d000000000d0000000000fffefeeeeeeddddddddddddddd
-- 037:efefefefefefefffffffffffffff000000000000000000000000000111ffffffffefefefefeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000dddddddddddddddddddddddddddddddddeeeeeeeefefff000000000000000000000000d0000dd0000d000000000fffefeeeeeedddddddddddddddd
-- 038:fffffffffffffffffffffffff0000000000000000000000000000000c11ffffffffffefefefefeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000dddddddddddddddddddddddddddddddddeeeeeeefeffff000000000000000000000000d00dd00dd000d0000000fffefeeeeeeddddddddddddddddd
-- 039:fffffffffffffffffffffff00000000000000000000000000000000ccc0fffffffffffefefefefeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddd0000ddddddddddddddddddddddddddddddddddeeeeeeefeffff0000000000000000000000d0dd000000dd0d000000fffefeeeeeddddddddddddddddddd
-- 040:ffffffffffffffffffff0000000000000000000000000000000000ccccc000fffffffffffefefefefeeeeeeeeeeeeeeeeeeeeedddddddddddddddd0000ddddddddddddddddddddddddddddddddddeeeeeeeefefff0000000000000000000000dd0000000000ddd0000fffefeeeeedddddddddddddddddddd
-- 041:fffffffffffffff00000000000000000000000000000000000000ccccccc0000ffffffffffefefefefeeeeeeeeeeeeeeeeeeeedddddddddddddddd0000dddddddddddddddddddddddddddddddddddeeeeeeeefefff00000000000000000000d00000000000000d000fffefeeeeeddddddddddddddddddddd
-- 042:000000000000000000000000000000000000000000000000000000ccccc00000000ffffffffffefefefeeeeeeeeeeeeeeeeeeedddddddddddddddd0000dddddddddddddddddddddddddddddddddddeeeeeeefefffff0000000000000000000765cccccccccc56700fffeeeeeeddddddddddddddddddddddd
-- 043:0000000000000000000000000000000000000000000000000000000ccc00000000000fffffffffefefefeeeeeeeeeeeeeeeeeedddddddddddddddd0000ddddddddddddddddddddddddddddddddddddeeeeeeefeffff0000000000000000065cccc56700765cccc56ffeeeeeedddddddddddddddddddddddd
-- 044:00000000000000000000000000000000000000000000000000000000c0000000000000fffffffffefefefeeeeeeeeeeeeeeeeedddddddddddddddd0000ddddddddddddddddddddddddddddddddddddeeeeeeeefeffff0000000000000005ccc56000000000065ccc5eeeeeeddddddddddddddddddddddddd
-- 045:000000000000000000000000000000000000000000000000000000000000000000000000ffffffffefefefeeeeeeeeeeeeeeeedddddddddddddddd0000dddddddddddddddddddddddddddddddddddddeeeeeeeefeffff00000000000005cc56000000000000ff65cc5eeeddddddddddddddddddddddddddd
-- 046:0000000000000000000000000000000000000000000000000000000000000000000000000ffffffffefefefeeeeeeeeeeeeeeedddddddddddddddd0000ddddddddddddddddddddddddddddddddddddddeeeeeeeefeffff000000000000cc50000000000000fffef5cceedddddddddddddddddddddddddddd
-- 047:0000000000000000000000000000000000000000000000000000000000000000000000000fffffffffefefefeeeeeeeeeeeeeedddddddddddddddd0000dddddddddddddddddddddddddddddddddddddddeeeeeeeefefffff0000000000c5000000000000ffffefee5ceddddddddddddddddddddddddddddd
-- 048:000000000000000000000000000000000000000000000000000000000d0000000000000000fffffffffefefeeeeeeeeeeeeeeeeddddddddddddddd0000ddddddddddddddddddddddddddddddddddddddddeeeeeeeefefffff00000000000000000000ffffefeeeeeeddddddddddddddddddddddddddddddd
-- 049:000000000000000000000000000000000000000000000000000000000dd000000000000000ffffffffefefefeeeeeeeeeeeeeeeddddddddddddddd0000dddddddddddddddddddddddddddddddddddddddddeeeeeeeefeffffff0000000000000000fffffefeeeeeedddddddddddddddddddddddddddddddd
-- 050:000000000000000000000000000000000000000000000000000000000d0d00000000000000fffffffffefefefeeeeeeeeeeeeeeedddddddddddddd0000ddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefefffffff00000000ffffffefeeeeeeedddddddddddddddddddddddddddddddddd
-- 051:00000000000000000000000000000000000000000000000000000000d00d00000000000000ffffffffffefefefeeeeeeeeeeeeeeeddddddddddddd0000dddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefefefffffffffffffffefefeeeeeedddddddddddddddddddddddddddddddddddd
-- 052:00000000000000000000000000000000000000000000000000000000d000d0000000000000fffffffffefefefeeeeeeeeeeeeeeeeedddddddddddd0000ddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeefefefefffffffefefefeeeeeeeeddddddddddddddddddddddddddddddddddddd
-- 053:00000000000000000000000000000000000000000000000000000000d0000d00000000000fffffffffffefefefeeeeeeeeeeeeeeeeeddddddddddd0000dddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeefefefefefefefeeeeeeeeeddddddddddddddddddddddddddddddddddddddd
-- 054:00000000000000000000000000000000000000000000000000000000d00000d00000000ffffffffffffefefefeeeeeeeeeeeeeeeeeeeeddddddddd0000ddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeefeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddd
-- 055:0000000000000000000000000000000000000000000000000000000d000000d00000ffffffffffffffefefefefeeeeeeeeeeeeeeeeeeeeeeeddddd0000ddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddd
-- 056:ffffffffffffffffffffffffffffffffff0000000000000000fffffdfffffffdfffffffffffffffffefefefefefeeeeeeeeeeeeeeeeeeeeeeeeeee0000ddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddd
-- 057:fffffffffffffffffffffffffffffffffffffffffffffffffffffffdffffffffdfffffffffffffffefefefefefeeeeeeeeeeeeeeeeeeeeeeeeeeee0000ddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddd
-- 058:fffffffffffffffffffffffffffffffffffffffffffffffffffffffdfffffffffdfffffffffffffefefefefefefeeeeeeeeeeeeeeeeeeeeeeeeeee0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 059:ffffffffffffffffffffffffffffffffffffffffffffffffffffffdffffddfffffdfffffffefefefefefefefefeeeeeeeeeeeeeeeeeeeeeeeeeeee0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 060:fefefefefefefefefefefefefefefefefefefefefefefefefefefedefedefdddfedefefefefefefefefefefefefeeeeeeeeeeeeeeeeeeeeeeeeeee0000eddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 061:efefefefefefefefefefefefefefefefefefefefefefefefefefefdfedefefefddddefefefefefefefefefefefeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 062:fefefefefefefefefefefefefefefefefefefefefefefefefefefededefefefefefddefefefefefefefefefefefeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 063:efefefefefefefefefefefefefefefefefefefefefefefefefefededefefefefefefefefefefefefefefefefefeeeeeeeeeeeeeeeeeeeeeeeeeeee0000eeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 064:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefefefefefefefefefefefe0000eeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 065:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefefefefefefefefefefefef0000eeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 070:eddddddddddddddddddddddddddddddddddddddddddeeeeeeeeefefefefefffffffffffffffffff0000000000000000000000000000000000000000000fefefefefefefefefefefefefefefefefefefefeeeeeeeeeedddddddddddddddddddddddddddddddddddeeeeeeeefeffff22222222222222222222
-- 071:ddddddddddddddddddddddddddddddddddddddddddeeeeeeeeefefeffffffffffffffffffffff000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffefefefefeeeeeeeeeeeddddddddddddddddddddddddddddddddeeeeeeeefeffff222222222222222222222
-- 072:ddddddddddddddddddddddddddddddddddddddddddeeeeeeeefeffffffffffffffffffffff000000000000000000000000000000000000000000000000fffffffffffffffffffffffffffffffffffffefefefeeeeeeeeeddddddddddddddddddddddddddddddeeeeeeeefeffff0000000000000000000000
-- 073:dddddddddddddddddddddddddddddddddddddddddeeeeeefefeffffffffff0000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffefefefeeeeeeeeedddddddddddddddddddddddddddeeeeeeeeefeffff00000000000000000000000
-- 074:ddddddddddddddddddddddddddddddddddddddddeeeeeefefeffffff0000000000000000000000000000000000000000000000000000000000000f0000fffffffffffffffffffffffffffffffffffffffffefefeeeeeeeeeeddddddddddddddddddddddddeeeeeeeeefefff0000000000000000000000000
-- 075:ddddddddddddddddddddddddddddddddddddddddeeeeefefeffff000000000000000000000000000000000000000000000000000000000000000ff000022000000000000000000000000000000ffffffffffefefeeeeeeeeeedddddddddddddddddddddeeeeeeeefefefff00000000000000000000000000
-- 076:dddddddddddddddddddddddddddddddddddddddeeeeefefefff00000000000000000000000000000000000000000000000000000000000000000ff000022000000000000000000000000000000000ffffffffefefeeeeeeeeeeedddddddddddddddddeeeeeeeeefefffff000000000000000000000000000
-- 077:ddddddddddddddddddddddddddddddddddddddeeeeeeefffff00000000000000000000000000000000000000000000000000000000000000000fff00002200000000000000000000000000000000000fffffffefefeeeeeeeeeeeeddddddddddddeeeeeeeeeeefefffff0000000000000000000000000000
-- 078:ddddddddddddddddddddddddddddddddddddddeeeeeeffff000000000000000000000000000000000000000000000000000000000000000000fffe0000220000000000000000000000000000000000000ffffffefefeeeeeeeeeeeeeeeeddeeeeeeeeeeeeeeefeffff000000000000000000000000000000
-- 079:dddddddddddddddddddddddddddddddddddddeeeeeeffff000000000000000000000000000000000000000000000000000000000000000000fffff00002200000000000000000000000000000000000000ffffffefefeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefeffff0000000000000000000000000000000
-- 080:ddddddddddddddddddddddddddddddddddddeeeeeeffff0000000000000000000000000000000000000000000000000000000000000000000ffffe000022000000000000000000000000000000000000000ffffffefefeeeeeeeeeeeeeeeeeeeeeeeeeeefefffff000000000000000000000000000000000
-- 081:ddddddddddddddddddddddddddddddddddddeeeeeffff0000000000000000000000000000000000000000000000000000000000000000000ffffef000022000000000000000000000000000000000000000fffffffefefeeeeeeeeeeeeeeeeeeeeeeefefefffff0000000000000000000000000000000000
-- 082:dddddddddddddddddddddddddddddddddddeeeeefeff00000000000000000000000000000000000000000000000000000000000000000000fffefe0000220000000000000000000000000000000000000000fffffffefefefeeeeeeeeeeeeeeeeeeefefeffff000000000000000000000000000000000000
-- 083:ddddddddddddddddddddddddddddddddddeeeeefeff00000000000000000000000000000000000000000000000000000000000000000000fffefee0000220000000000000000000000000000000000000000ffffffffefefefeeeeeeeeeeeeefefefefffff00000000000000000000000000000000000000
-- 084:ddddddddddddddddddddddddddddddddddeeeefeff000000000000000000000000000000000000000000000000000000000000000000000ffffefe0000220000000000000000000000000000000d000000000ffffffffefefefefefeeefefefefefefffff000000000000000000000000000000000000000
-- 085:dddddddddddddddddddddddddddddddddeeeefeff0000000000000000000000000000000000000000000000000000000000000000000000fffefee0000220000000000000000000000000000000d000000000fffffffffefefefefefefefefefeffffff00000000000000000000000000000000000000000
-- 086:dddddddddddddddddddddddddddddddddeeefeff0000000000000000000000000000000000000000000000000000000000000000000000fffefeee000022000000000000000000000000000000d0d00000000ffffffffffefefefefefefefefffffff0000000000000000000000000000000000000000000
-- 087:ddddddddddddddddddddddddddddddddeeeeefff0000000000000000000000000000000000000000000000000000000000000000000000ffffefee000022000000000000000000000000000000d0d00000000fffffffffffefefefefefeffffffff000000000000000000000000000000000000000000000
-- 088:dddddddddddddddddddddddddddddddeeeeefff00000000000000000000000000000000000000000000000000000000000000000000000fffefeee00002200000000000000000000000000000d000d0000000ffffffffffffffefefffffffffff00000000000000000000000000000000000000000000000
-- 089:dddddddddddddddddddddddddddddddeeeefff000000000000000000000000000000000000000000000000000000000000000000000000ffefeeee00002200000000000000000000000000000d000d000000ffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000
-- 090:ddddddddddddddddddddddddddddddeeeefff000000000000000000000000000000000000000000000000000000000000000000000000ffffefeee0000220000000000000000000000000000d0000d00000fffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000
-- 091:ddddddddddddddddddddddddddddddeeefef0000000000000000000000000000000000000000000000000000000000000000000000000fffefeeee0000220000000000000000000000000000d00000d00fffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000
-- 092:dddddddddddddddddddddddddddddeeefeff0000000000000000000000000000000000000000000000000000000000000000000000000ffffefeee00002200000fffff00000000000000000d0000ffdffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000
-- 093:ddddddddddddddddddddddddddddeeeeeff00000000000000000000000000000000000000000000000000000000000000000000000000fffefeeee0000fffffffffffffffffffffffffffffdfffffffdfffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000
-- 094:ddddddddddddddddddddddddddddeeeeff000000000000000000000000000000000000000000000000000000000000000000000000000ffffefeee0000ffffffffffffffffffffffffffffdffffffffdffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000
-- 095:dddddddddddddddddddddddddddeeeefff000000000000000000000000000000000000000000000000000000000000000000000000000fffefeeee0000ffffffffffffffffffffffffffffdfffffffffdffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000
-- 096:dddddddddddddddddddddddddddeeefff0000000000000000000000000000000000000000000000000000000000000000000000000000ffffefeee0000fffffffffffffffffffffffffffdffffddffffdffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000
-- 097:ddddddddddddddddddddddddddeeefef00000000000000000000000000000000000000000000000000000000000000000000000000000fffefeeee0000efefefefefefefefefefefefefedefddefddefdfefefefefffffffffff000000000000000000000000000000000000000000000000000000000000
-- 098:dddddddddddddddddddddddddeeeeeff00000000000000000000000000000000000000000000000000000000000000000000000000000ffffefeee0000fefefefefefefefefefefefefededdfefefedefdfefefefeffffffffff000000000000000000000000000000000000000000000000000000000000
-- 099:dddddddddddddddddddddddddeeeeff000000000000000000000000000000000000000000000000000000000000000000000000000000fffefeeee0000efefefefefefefefefefefefefddefefefefededefefefefefffffffff000000000000000000000000000000000000000000000000000000000000
-- 100:ddddddddddddddddddddddddeeeeff0000000000000000000000000000000000000000000000000000000000000000000000000000000ffffefeee0000eeeeeeeeeeeeeefefefefefefdfefefefefefedddefefefefeffffffff0000000000000000cccc0000000000000000000000000000000000000000
-- 101:dddddddddddddddddddddddeeeefff0000000000000000000000000000000000000000000000000000000000000000000000000000000fffefefee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefdfefefefefefffffff00000000000000ccddddcc00000000000000000000000000000000000000
-- 102:dddddddddddddddddddddddeeefff00000000000000000000000000000000000000000000000000000000000000000000000000000000ffffefeee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefefeffffff0000000000000cdde00eddc0000000000000000000000000000000000000
-- 103:ddddddddddddddddddddddeeefef000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffefee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefefffff000000000000cde000000edc000000000000000000000000000000000000
-- 104:dddddddddddddddddddddeeeeeff0000000000000000000000000000000000000000000000000000000000000000000000000000000000fffefefe0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefefffff0000000000cde000c0000edc00000000000000000000000000000000000
-- 105:dddddddddddddddddddddeeeeff00000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffefee0000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefeffffff0000000000cd000ccc0000dc00000000000000000000000000000000000
-- 106:ddddddddddddddddddddeeeeff000000000000000000000000000000000000000000000000000000000000000000000000000000000000fffffefe0000ddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefffff000000000cde00ccccc000edc0000000000000000000000000000000000
-- 107:dddddddddddddddddddeeeefff000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffef0000ddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefffff00000000cd00ccccccc000dc0000000000000000000000000000000000
-- 108:ddddddddddddddddddeeeefff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffefe0000ddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefeffff00000000cd000ccccc0000dc0000000000000000000000000000000000
-- 109:dddddddddddddddddeeeefff00000000000000000000000000000000000d000000000000000000000000000000000000000000000000000fffffef0000dddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeefefffff00000000cde000ccc0000edc0000000000000000000000000000000000
-- 110:dddddddddddddddddeeefef000000000000000000000000000000000000d0000000000000000000000000000000000000000000000000000fffffe0000dddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeefefffff00000000cd0000c00000dc00000000000000000000000000000000000
-- 111:ddddddddddddddddeeefeff00000000000000000000000000000000000d0d000000000000000000000000000000000000000000000000000ffffff0000ddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeefefeffff00000000cde00000000edc00000000000000000000000000000000000
-- 112:dddddddddddddddeeefeff000000000000000000000000000000000000d0d0000000000000000000000000000000000000000000000000000fffff0000dddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeefefeffff00000000cde000000edc000000000000000000000000000000000000
-- 113:ddddddddddddddeeefeff000000000000000000000000000000000000d000d0000000000000000000000000000000000000000000000000000ffff0000dddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeefefffff000000000cdde00eddc0000000000000000000000000000000000000
-- 114:dddddddddddddeeeeeff0000000000000000000000000000000000000d000d0000000000000000000000000000000000000000000000000000ffff0000dddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeefefffff000000000ccddddcc00000000000000000000000000000000000000
-- 115:ddddddddddddeeeeeff0000000000000000000000000000000000000d00000d0000000000000000000000000000000000000000000000000000fff0000ddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefefeffff00000000000cccc0000000000000000000000000000000000000000
-- 116:dddddddddddeeeeeff00000000000000000000000000000000000000d00000d00000000000000000000000000000000000000000000000000000ff0000dddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefefeffff000000000000000000000000000000000000000000000000000000
-- 117:ddddddddddeeeeefff0000000000000000000000000000000000000d000000d000000000000000000000000000000000000000000000000000000f0000dddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeefefffff000000000000000000000000000000000000000000000000000000
-- 118:dddddddddeeeeefff00000000000000000000000000000000000000d0000000d0000000000000000000000000000000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefefefffff0000000000000000000000000000000000000000000000000000f
-- 119:ddddddddeeeeefff00000000000000000000000000000000000000d00000000d000000000000000ffffffffffffff00000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeefefefffff00000000000000000000000000000000000000000000000000ff
-- 120:ddddddeeeeeefff000000000000000000000000000000000000000d000000000d00000000000ffffffffffffffffffff00000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeefefefffff000000000000000000000000000000000000000000000000fff
-- 121:dddddeeeeeefff000000000000000000000000000000000000000d0000dd0000d000000000ffffffffefefffffffffffff000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeefefefffffff0000000000000000000000000000000000000000000000ffff
-- 122:ddddeeeeeefff0000000000000000000000000000000000000000d00dd00dd000d000000fffffefefefefefefefffffffff00000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeefefefffffff0000000000000000000000000000000000000000000fffefe
-- 123:dddeeeeeeffff000000000000000000000000000000000000000d0dd000000dd0d0000ffffffefefefefefefefefefffffff0000000000000000000000ddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeefefefffffff00000000000000000000000000000000000000000fffefee
-- 124:ddeeeeeefeff0000000000000000000000000000000000000000dd0000000000ddd0fffffefefefeeeeeeefefefefefffffff000000000000000000000dddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeefefeffffffff0000000000000000000000000000000000000ffffefeee
-- 125:eeeeeeefeff0000000000000000000000000000000000000000d00000000000000dfffffefefeeeeeeeeeeeeefefefefffffff00000000000000000000dddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeefefefefffffffff000000000000000000000000000000000fffffefeeee
-- 126:eeeeeefeff00000000000000000000000000000000000000000765cccccccccc567ffefefeeeeeeeeeeeeeeeeeeefefefffffff0000000000000000000dddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeefefefeffffffffff00000000000000000000000000000ffffffefeeeee
-- 127:eeeeefeff000000000000000000000000000000000000000065cccc56700765cccc56fefeeeeeeeeeeeeeeeeeeeeefefeffffff0000000000000000000dddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefefeffffffffffffff000000000000000000000ffffffefefeeeeee
-- 128:eeeefeff00000000000000000000000000000000000000005ccc56000000000f65ccc5eeeeeeeeeeeeeeeeeeeeeeeefefeffffff000000000000000000ddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefefefefffffffffffffffffffffffffffffffffffffefefeeeeeee
-- 129:eeefefff0000000000000000000000000000000000000005cc560000000000ffff65cc5eeeeeeeeeeeeeeeeeeeeeeeefefefffff000000000000000000ddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefefefefefffffffffffffffffffffffffffffffefefefeeeeeeee
-- 130:eefefff0000000000000000000000000000000000000000cc500000000000ffffefe5cceeeeeeeeeddeeeeeeeeeeeeeefefefffff00000000000000000ddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefefefefefefefefffffffffffffffffffffffefefefeeeeeeeeeed
-- 131:efefff00000000000000000000000000000000000000000c500000000000ffffefeee5ceeeeeddddddddddeeeeeeeeeeefefeffff00000000000000000ddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefefefefefefefefefefefefefefefefefefefefefeeeeeeeeeedd
-- 132:fefff000000000000000000000000000000000000000000000000000000ffffefeeeeeeeeeddddddddddddddeeeeeeeeeefeffffff0000000000000000dddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefefefefefefefefefefefefefefefefefefefefefeeeeeeeeeeddd
-- 133:efff0000000000000000000000000000000000000000000000000000000fffefeeeeeeeedddddddddddddddddeeeeeeeeeefefffff0000000000000000ddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefefefefefefefefefefefefefefefefefefefeeeeeeeeeeeedddd
-- 134:ffff222222222222222222222222222222222222222222222222222222fffefeeeeeeeedddddddddddddddddddeeeeeeeefefeffff2222222222220000ddddddddeeeeeeeeeeeeeeeeeeeefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefefeeeeeeeeeeeeeeeeeeeeddddd
-- 135:fff222222222222222222222222222222222222222222222222222222fffefeeeeeeeedddddddddddddddddddddeeeeeeeefeffffff222222222220000dddddddeeeeeeeeeeeefefefefefefefefefefefefefefefefefefefefefeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddd
-- </SCREEN>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

