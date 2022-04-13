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
sub=string.sub
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
				
				loot(j)
		
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

function loot(j)
		local s=ships[j]
		for i=0,9-1 do
				if inventory[j][i+1] then
						create_powerup(math.floor(s.x-24),math.floor(s.x+24),math.floor(s.y-24),math.floor(s.y+24),inventory[j][i+1].id)
				end
		end
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
		if s.wasmod and #s.wasmod>0 then
				local points={--{s.x-cos(s.a)*8,s.y-sin(s.a)*8},
			               {x=s.x+cos(s.a)*4,y=s.y+4*sin(s.a)},
												      {x=s.x-cos(s.a-2*pi/3-0.3)*11,y=s.y-sin(s.a-2*pi/3-0.3)*11},
												      {x=s.x-cos(s.a+2*pi/3+0.3)*11,y=s.y-sin(s.a+2*pi/3+0.3)*11}}
				local hyp=math.sqrt(32)
		
				for g,core in ipairs(s.wasmod) do
				--if inventory[k][h] and inventory[k][h].mod and sub(inventory[k][h].mod,1,4)=='core' then
				--local core= tonumber(sub(inventory[k][h].mod,5,5))
				local pt=points[core]
				
				clear_sprite2({oldpos={x=pt.x-4+cos(s.a)*4,y=pt.y-4+sin(s.a)*4}},hyp)
				
				end
				
				s.wasmod=nil
				
		end
		
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
		s.aim1=nil
		s.target1=nil
		s.aim2=nil
		s.target2=nil
		for i=1,2 do
		local id
		if s[fmt('shot%d',i)] then 
		
		id= inventory[j][s[fmt('shot%d',i)].invi].id

		local autoaim=nil
		for k=0,9-1 do
				if inventory[j][k] and inventory[j][k].mod==fmt('shot%d',i) then
						autoaim=true
						break
				end
		end
		
		if autoaim then 
				local distances={}
				for j2,s2 in ipairs(ships) do
						if s2~=s then
								ins(distances,{s=s2,d=math.sqrt((s.x-s2.x)^2+(s.y-s2.y)^2)})
						end
				end
				table.sort(distances,function(a,b) return a.d<b.d end)
				if distances[1] and distances[1].d<=140 then
						local s2=distances[1].s
						s[fmt('aim%d',i)]=math.atan2(s2.y-s.y,s2.x-s.x)
						s[fmt('target%d',i)]=s2
				end
		end

		end

		if ((btnp((s.id-1)*8+4+i-1) and id~=19) or (id==19 and t%6==0)) and not s.onbase then 
				if s[fmt('shot%d',i)] then 
						if s[fmt('shot%d',i)].nrj>0 then
						
						local aim=s.a+pi
						if s[fmt('aim%d',i)] then aim=s[fmt('aim%d',i)] end
						if id==32 then ins(shots,{x=s.x-3,y=s.y-3,id=id,dx=cos(aim)*3,dy=sin(aim)*3,owner=s}) end
						if id==50 then ins(shots,{x=s.x-3,y=s.y-3,id=id,dx=cos(aim)*3,dy=sin(aim)*3,owner=s}) end
						if id==49 then ins(static,{x=s.x-3,y=s.y-3,id=id,dx=0,dy=0,owner=s,iframes=90}) end
						if id==34 then ins(missiles,{x=s.x-4,y=s.y-4,a=aim,id=id,dx=cos(aim)*5,dy=sin(aim)*5,owner=s}) end
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
										ins(lazers,{x=s.x-4,y=s.y-4,a=a,dx=cos(a)*3,dy=sin(a)*3,id=id,owner=s})
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
												ins(distances,{s=s,d=math.sqrt((st.x-s.x)^2+(st.y+sin(t*0.08)*2.5-s.y)^2)})
										end
								end
								table.sort(distances,function(a,b) return a.d<b.d end)
								if distances[1] and distances[1].d<=140 then
										local s=distances[1].s
										local a=math.atan2(s.y-(st.y+sin(t*0.08)*2.5),s.x-st.x)
										ins(lazers,{x=st.x,y=st.y+sin(t*0.08)*2.5,a=a,dx=cos(a)*3,dy=sin(a)*3,owner=st,id=19})
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
						if sprpix(sh.id,lx,ly)~=0 and is_solid(pixels[posstr(sh.x+lx,sh.y+ly)]) then

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
		
		for i=#static,1,-1 do
				local st=static[i]
				for j,s in ipairs(ships) do
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				for lx=0,7 do for ly=0,7 do
				if sprpix(st.id,lx,ly)~=0 then
						local sx,sy=cams[j].ax+st.x+lx-cams[j].x,cams[j].ay+math.floor(st.y+sin(t*0.08)*2.5)+ly-cams[j].y
						local p
						
						if sx<cams[j].ax or sx>=cams[j].ax+cams[j].aw or sy<cams[j].ay or sy>=cams[j].ay+cams[j].ah then
						p= 0
						else
						p= pix(sx,sy)
						end
						--trace(p)
						--trace(fmt('st.iframes %d',st.iframes))
						if (st.id==49 and st.iframes==0 and p>2 and p~=12) or (st.id==17 and p>4) then
						--trace(fmt('got this far, %d',p))
						
						trace(fmt('static hit %d @ %d,%d (%d,%d)',p,math.floor(cams[j].ax+st.x+lx-cams[j].x),math.floor(cams[j].ay+st.y+sin(t*0.08)*2.5+ly-cams[j].y),math.floor(st.x),math.floor(st.y+sin(t*0.08)*2.5)))
						
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
								explode(ms)
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
		[34]={30,spawn=51},
		[49]={35},
		[50]={55},
		[19]={10,spawn=21},		
		[21]={10},
		[51]={20},
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
		local points={{s.x-cos(s.a)*8,s.y-sin(s.a)*8},
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
		
		if boosted(k) then
		s.wasmod={}
		
		local points={--{s.x-cos(s.a)*8,s.y-sin(s.a)*8},
	               {x=s.x+cos(s.a)*4,y=s.y+4*sin(s.a)},
										      {x=s.x-cos(s.a-2*pi/3-0.3)*11,y=s.y-sin(s.a-2*pi/3-0.3)*11},
										      {x=s.x-cos(s.a+2*pi/3+0.3)*11,y=s.y-sin(s.a+2*pi/3+0.3)*11}}
		local hyp=math.sqrt(32)
		local dsx=0
		if math.abs(s.dx)>0.2 or math.abs(s.dy)>0.2 then
		dsx=2*8
		end
		
		for h=0,9-1 do
		if inventory[k][h] and inventory[k][h].mod and sub(inventory[k][h].mod,1,4)=='core' then
		local core= tonumber(sub(inventory[k][h].mod,5,5))
		ins(s.wasmod,core)
		local pt=points[core]
		local a={x=cos(s.a+pi-pi/4)*hyp,y=sin(s.a+pi-pi/4)*hyp}; local d={x=cos(s.a+pi+pi/4)*hyp,y=sin(s.a+pi+pi/4)*hyp}
		local b={x=cos(s.a+pi+pi/4)*hyp,y=sin(s.a+pi+pi/4)*hyp}; local e={x=cos(s.a+pi-pi+pi/4)*hyp,y=sin(s.a+pi-pi+pi/4)*hyp}
		local c={x=cos(s.a+pi-pi+pi/4)*hyp,y=sin(s.a+pi-pi+pi/4)*hyp}; local f={x=cos(s.a+pi-pi-pi/4)*hyp,y=sin(s.a+pi-pi-pi/4)*hyp}
		textri(cams[j].ax-cams[j].x+pt.x+cos(s.a)*4+a.x,cams[j].ay-cams[j].y+pt.y+sin(s.a)*4+a.y,
		       cams[j].ax-cams[j].x+pt.x+cos(s.a)*4+b.x,cams[j].ay-cams[j].y+pt.y+sin(s.a)*4+b.y,
		       cams[j].ax-cams[j].x+pt.x+cos(s.a)*4+c.x,cams[j].ay-cams[j].y+pt.y+sin(s.a)*4+c.y,

		       2*8+dsx,0*8,
									2*8+dsx+7,0*8,
									2*8+dsx,0*8+7, 
									
									false, 0)
		textri(cams[j].ax-cams[j].x+pt.x+cos(s.a)*4+d.x,cams[j].ay-cams[j].y+pt.y+sin(s.a)*4+d.y,
		       cams[j].ax-cams[j].x+pt.x+cos(s.a)*4+e.x,cams[j].ay-cams[j].y+pt.y+sin(s.a)*4+e.y,
		       cams[j].ax-cams[j].x+pt.x+cos(s.a)*4+f.x,cams[j].ay-cams[j].y+pt.y+sin(s.a)*4+f.y,

		       2*8+dsx+7,0*8,
									2*8+dsx,0*8+7,
									2*8+dsx+7,0*8+7, 
									
									false, 0)
		
		end
		end end
		--pix(cam.ax+s.x-cam.x,cam.ay+s.y-cam.y,2)
		end
end

function boosted(j)
		for i=0,9-1 do
				if inventory[j][i+1] and inventory[j][i+1].mod and sub(inventory[j][i+1].mod,1,4)=='core' then 
						return true
				end
		end
end

keymap={}

function UIdraw(j)
		
		local s=ships[j]
		local cam=cams[j]

		local rw=s.hp/30*(cam.aw-8)
		local ry=cam.ay+3
		if alerts[j] and #alerts[j].msgs>0 then ry=ry+8 end
		rect(cam.ax+4,ry,rw,2,6)
		for i=1,2 do
		if s[fmt('shot%d',i)] then
		rw=s[fmt('shot%d',i)].nrj/max_nrj(j,i)*((cam.aw-4*3)/2)
		rect(cam.ax+4+(i-1)*((cam.aw-4*3)/2+4),cam.ay+cam.ah-1-4,rw,2,1)
		end
		end

		for i=1,2 do
		if s[fmt('target%d',i)] then
				local tgt=s[fmt('target%d',i)]
				local aim=s[fmt('aim%d',i)]
				line(cam.ax+s.x+math.cos(aim)*12-cam.x,cam.ay+s.y+math.sin(aim)*12-cam.y,
				     cam.ax+s.x+math.cos(aim-pi/5)*8-cam.x,cam.ay+s.y+math.sin(aim-pi/5)*8-cam.y,4)
				line(cam.ax+s.x+math.cos(aim)*12-cam.x,cam.ay+s.y+math.sin(aim)*12-cam.y,
				     cam.ax+s.x+math.cos(aim+pi/5)*8-cam.x,cam.ay+s.y+math.sin(aim+pi/5)*8-cam.y,4)
				spr(70,cam.ax+tgt.x-8-cam.x,cam.ay+tgt.y-8-cam.y,0,1,0,0,2,2)
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
										else 
										if inventory[j][inventory[j].i] and inventory[j][inventory[j].i].id==21 then if inventory[j][inventory[j].i].mod=='shot1' then inventory[j][inventory[j].i].mod=nil else inventory[j][inventory[j].i].mod='shot1' end
										elseif inventory[j][inventory[j].i] and inventory[j][inventory[j].i].id==51 then if inventory[j][inventory[j].i].mod and sub(inventory[j][inventory[j].i].mod,1,4)=='core' then inventory[j][inventory[j].i].mod=nil 
												else 
												local core=nil
												for c=1,3 do if not core then for k=0,9-1 do
														if inventory[j][k+1] and inventory[j][k+1].mod and sub(inventory[j][k+1].mod,1,4)=='core' then
																if tonumber(sub(inventory[j][k+1].mod,5,5))==c then break end
														end
														if k==9-1 then core=c end
												end end end
												if core then
														inventory[j][inventory[j].i].mod=fmt('core%d',core)
												end
												end
										else
										if inventory[j][inventory[j].i] then local oldshot1=s.shot1; if oldshot1 then inventory[j][oldshot1.invi].nrj=oldshot1.nrj end; s.shot1={invi=inventory[j].i,nrj=inventory[j][inventory[j].i].nrj or idtags[inventory[j][inventory[j].i].id].nrj}; if s.shot2 and s.shot2.invi==inventory[j].i then s.shot2=nil end end 
										end
										end
										end
										if i==5 then 
										if inventory[j][inventory[j].i] and inventory[j][inventory[j].i].id==21 then if inventory[j][inventory[j].i].mod=='shot2' then inventory[j][inventory[j].i].mod=nil else inventory[j][inventory[j].i].mod='shot2' end
										elseif inventory[j][inventory[j].i] and inventory[j][inventory[j].i].id==51 then if inventory[j][inventory[j].i].mod and sub(inventory[j][inventory[j].i].mod,1,4)=='core' then inventory[j][inventory[j].i].mod=nil 
												else 
												local core=nil
												for c=1,3 do if not core then for k=0,9-1 do
														if inventory[j][k+1] and inventory[j][k+1].mod and sub(inventory[j][k+1].mod,1,4)=='core' then
																if tonumber(sub(inventory[j][k+1].mod,5,5))==c then break end
														end
														if k==9-1 then core=c end
												end end end
												if core then
														inventory[j][inventory[j].i].mod=fmt('core%d',core)
												end
												end
										else
										if inventory[j][inventory[j].i] then local oldshot2=s.shot2; if oldshot2 then inventory[j][oldshot2.invi].nrj=oldshot2.nrj end; s.shot2={invi=inventory[j].i,nrj=inventory[j][inventory[j].i].nrj or idtags[inventory[j][inventory[j].i].id].nrj}; if s.shot1 and s.shot1.invi==inventory[j].i then s.shot1=nil end end 
										end
										end
								end
								if keymap[j] then keymap[j][(s.id-1)+i]=nil end
						end
				end
				if scrapping and inventory[j][inventory[j].i] then
				local id=inventory[j][inventory[j].i].id 
				inventory[j][inventory[j].i]=nil 
				local scrapres=scrapvals[id]
				if scrapres.spawn then inventory[j][inventory[j].i]={id=scrapres.spawn}; alert(j,fmt('Salvaged %s!',idtags[scrapres.spawn][1]),true) end
				scrap[ships[j].id]=scrap[ships[j].id]+scrapres[1]
				alert(j,fmt('Got %d scrap. (%d total)',scrapres[1],scrap[ships[j].id]),true)
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
						for k=1,2 do
						if (s[fmt('shot%d',k)] and i+1==s[fmt('shot%d',k)].invi) or (inventory[j][i+1] and inventory[j][i+1].mod==fmt('shot%d',k)) then
								local tw=print(fmt('S%d',k),0,-6,12)
								local th=0
								if idtag_tw and AABB(idtag_tx,cam.ay+cy+6+2,idtag_tw,5,cam.ax+cx-6*9+i*12+1,cam.ay+cy-6+12+2,tw,5) then th=6+2 end
								dropshadow(fmt('S%d',k),cam.ax+cx-6*9+i*12+1,cam.ay+cy-6+12+2+th)
								print(fmt('S%d',k),cam.ax+cx-6*9+i*12+1,cam.ay+cy-6+12+2+th,12)
						end
						end
						if inventory[j][i+1] and inventory[j][i+1].mod and sub(inventory[j][i+1].mod,1,4)=='core' then
								local core=tonumber(sub(inventory[j][i+1].mod,5,5))
								local tw=print(fmt('C%d',core),0,-6,12)
								local th=0
								if idtag_tw and AABB(idtag_tx,cam.ay+cy+6+2,idtag_tw,5,cam.ax+cx-6*9+i*12+1,cam.ay+cy-6+12+2,tw,5) then th=6+2 end
								dropshadow(fmt('C%d',core),cam.ax+cx-6*9+i*12+1,cam.ay+cy-6+12+2+th)
								print(fmt('C%d',core),cam.ax+cx-6*9+i*12+1,cam.ay+cy-6+12+2+th,12)
						end
				end
				if not s.moved and not (s.shot1 and s.shot2) then
						local tw= print('Select weapons.',0,-6,12,false,1,true)
						dropshadow('Select weapons.',cam.ax+cx-tw/2,cam.ay+cy-6-8,true)
						print('Select weapons.',cam.ax+cx-tw/2,cam.ay+cy-6-8,12,false,1,true)
				end
				if not s.moved and (s.shot1 and s.shot2) then
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
		pick_up(j,34,true)
		pick_up(j,34,true)
		pick_up(j,34,true)
		return newship
end

powerups={}

function create_powerups()
		for i=1,5 do
		create_powerup(0,240*2-1,0,136*2-1)
		end
end

function create_powerup(minx,maxx,miny,maxy,id)
		local rx,ry=math.random(minx,maxx),math.random(miny,maxy)
		while pixels[posstr(rx,ry)] do
		rx,ry=math.random(minx,maxx),math.random(miny,maxy)
		end
		if not id then
		local type=math.random(1,5)
		if type==1 then id=32 end
		if type==2 then id=17 end
		if type==3 then id=34 end
		if type==4 then id=49 end
		if type==5 then id=50 end
		end
				
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
-- 011:0666666066677666667667666676676666777766667667667666666707777770
-- 012:0222222022111222221221222211122222122122221112221222222101111110
-- 013:0dddddd0dddddddddddeedddddeeeedddeeeeeedddddddddedddddde0eeeeee0
-- 014:0dddddd0dddddddddeeeeeedddeeeedddddeedddddddddddedddddde0eeeeee0
-- 017:000000000001100000211200d322223dd332233d012332100001100000000000
-- 019:0002000000131000002320000024200000242000002320000013100000020000
-- 021:0000000000200200002222000034430000211200002002000010010000000000
-- 023:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 024:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 025:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 026:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 027:0aaaaaa0aa9aa9aaaa9aa9aaaaa99aaaaa9aa9aaaa9aa9aa9aaaaaa909999990
-- 028:0333333033233233332332333332223333333233333223332333333202222220
-- 029:0dddddd0ddddeddddddeedddddeeeddddddeedddddddedddedddddde0eeeeee0
-- 030:0dddddd0dddedddddddeeddddddeeedddddeeddddddeddddedddddde0eeeeee0
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
-- 070:4444440044333300432000004300000043000000430000000000000000000000
-- 071:0044444400333344000002340000003400000034000000340000000000000000
-- 084:cd000000cd000000cdddd00d0cccc00c00000000000000000000000000000000
-- 085:00dc000000dc0000dddc0000ccc0000000000000000000000000000000000000
-- 086:0000000000000000430000004300000043000000432000004433330044444400
-- 087:0000000000000000000000340000003400000034000002340033334400444444
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
-- 000:111111111111111111111111111111111113333333333333333333333333333333333333311111111eeeeeeeeeeeeeeeeeeeeeeeeeeefefefffff30000111111111111111111111111111111111111111112222d2222dd2222d222222222222222222222211111111eeeeeeeeeeeeeeeeeeeeeeeeeeefefe
-- 001:11111111111111111111111111111111111333333333333333333333333333333333333311111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeefefefffff0000111111111111111111111111111111111111111112222d2222222222d22222222222222222222211111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeefef
-- 002:11111111111111111111111111111111111000000000000000000000000000000000000111111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefeffff00001111111111111111111111111111111111111111122222d222222222d22222222222222222222111111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 003:111166666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666efef000011111111111111111111111111111111111111111222222d22222222d22222222222222222221111111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 004:111166666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666fefe0000111111111111111111111111111111111111111112222222d222222d222222222222222222211111111111eeeeeeeedddddddddddddeeeeeeeeeee
-- 005:1111111111111111111111111111111111100000000000000000000000000000000011111111111eeeeeeddddddddd1ddddddddddeeeeeeeeeeeef0000111111111111111111111111111111111111111112222222d222222d22222222222222222211111111111eeeeeeddddddddd1ddddddddddeeeeeee
-- 006:1111111111111111111111111111111111110000000000000000000000000000000111111111111eeedddddddd111111111dddddddddeeeeeeeeee00001111111111111111111111111111111111111111112222222d22222d22222222222222222111111111111eeedddddddd111111111dddddddddeeee
-- 007:111111111111111111111111111111111111000000000000000000000000000000111111111111eeddddddddd11111111111ddddddddddeeeeeeee000011111111111111111111111111111111111111111122222222d133d22222222222222222111111111111eeddddddddd11111111111ddddddddddee
-- 008:11111111111111111111111111111111111110000000000000000000000000000111111111111eeddddddddd1111111111111dddddddddddeeeeee0000111111111111111111111111111111111111111111122222222d33d2222222222222222111111111111eeddddddddd1111111111111ddddddddddd
-- 009:1111111111111111111111111111111111111000000000000000000000000000111111111111edddddddddd111111111111111ddddddddddddeeee0000111111111111111111111111111111111111111111122222222d33d222222222222222111111111111edddddddddd111111111111111dddddddddd
-- 010:111111111111111111111111111111111111110000000000000000000000000111111111111edddddddddd11111111111111111dddddddddddddee00001111111111111111111111111111111111111111111122222222dd222222222222222111111111111edddddddddd11111111111111111ddddddddd
-- 011:1111111111111111111111111111111111111110000000000000000000000011111111111eeddddddddddd11111111111111111ddddddddddddddd000011111111111111111111111111111111111111111111122222224d4222222222222211111111111eeddddddddddd11111111111111111ddddddddd
-- 012:111111111111111111111111111111111111111000000000000000000000111111111111eeddddddddddd111111111111111111ddddddddddddddd0000111111111111111111111111111111111111111111111222222224222222222222111111111111eeddddddddddd111111111111111111ddddddddd
-- 013:111111111111111111d1111111111111111111110000000000000000000111111111111edddddddddddd1111111111111111111ddddddddddddddd0000111111111111111111111111d1111111111111111111112222222322222222222111111111111edddddddddddd1111111111111111111ddddddddd
-- 014:11111111111111111ddd11111111111111111111100000000000000000111111111111edddddddddddd111111111111111111111dddddddddddddd0000dd111111111111111111111ddd11111111111111111111122222231122222222111111111111edddddddddddd111111111111111111111dddddddd
-- 015:11111111111111111dddd111111111111111111111100000000000001111111111111edddddddddddd111111111111111111111ddddddddddddddd0000dd111111111111111111111dddd111111111111111111111122113112222221111111111111edddddddddddd111111111111111111111ddddddddd
-- 016:1111111111111111ddddddd111111111111111111111000000000011111111111111eddddddddddddd111111111111111111111ddddddddddddddd0000ddd1111111111111111111ddddddd111111111111111111111222222222211111111111111eddddddddddddd111111111111111111111ddddddddd
-- 017:111111111111111dddddddd11111111111111111111111110001111111111111111e1dd1dddddddddd111111111111111111111ddddddddddddddd0000dddd11111111111111111dddddddd11111111111111111111111112221111111111111111e1dd1dddddddddd111111111111111111111ddddddddd
-- 018:1111111111111dddddddddd1111111111111111111111111111111111111111111111111111ddddddd111111111111111111111ddddddddddddddd0000dddddd1111111111111dddddddddd1111111111111111111111111111111111111111111111111111ddddddd111111111111111111111ddddddddd
-- 019:d11111111111ddddddddddd11111111111111111111111111111111111111111111111111111ddddd111111111111111111111dddddddddddddddd0000ddddddd11111111111ddddddddddd1111111111111111111111111111111111111eeee111111111111ddddd111111111111111111111dddddddddd
-- 020:dddddd1dddddd1ddddddddd111111111111111111111111111111111111111111111111111111ddddd1111111111111111111ddddddddddddddddd0000dddddddddddd1dddddd1ddddddddd111111111111111111111111111111111111eeee11111111111111ddddd1111111111111111111ddddddddddd
-- 021:ddddddddd111111111dddddd111111111111111111111111111111111111111111111111111111dddd111111111111111111dddddddddddddddddd0000ddddddddddddddd111111111dddddd111111111111111111111111111111111111ee1111111111111111dddd111111111111111111dddddddddddd
-- 022:ddddddd1111111111111dddd111111111111111111111111111111111111111111111111111111dddd11111111111111111ddddddddddddddddddd0000ddddddddddddd1111111111111dddd111111111111111111111111111111111111ee1111111111111111dddd11111111111111111ddddddddddddd
-- 023:dddddd111111111111111dddd11111111111111111111111111111111111111111111111111111dddd11111111111111111ddddddddddddddddddd0000dddddddddddd111111111111111dddd11111111111111111111111111111111111e11111111111111111dddd11111111111111111ddddddddddddd
-- 024:ddddd11111111111111111ddd111111111111111111111111111111111111111111111111111111d111111111111111111dddddddddddddddddddd0000ddddddddddd11111111111111111ddd111111111111111111111113311111111111111111111111111111d111111111111111111dddddddddddddd
-- 025:ddddd11111111111111111dddd1111111111111111111111111111111111111111111111111111d11111111111111111111ddddddddddddddddddd0000ddddddddddd11111111111111111dddd1111111111111111111111332111111111111111111111111111d11111111111111111111ddddddddddddd
-- 026:dddd1111111111111111111dddd111111111111111111111111111111111111111111111111111111111111111111111111ddddddddddddddddddd0000dddddddddd1111111111111111111dddd111111111111111111112332111111111111111111111111111111111111111111111111ddddddddddddd
-- 027:dddd1111111111111111111ddddd111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddddddddd0000dddddddddd1111111111111111111ddddd111111111111111111124421111111111111111111111111111111111111111111111111dddddddddddd
-- 028:dddd1111111111111111111dddddd11111111111111111111111111111111111111111111111111111111111111111111111dddddddddddddddddd0000dddddddddd1111111111111111111dddddd11111111111111111124421111111111111111111111111111111111111111111111111dddddddddddd
-- 029:dddd1111111111111111111dd1ddddd111111111111111111111111111111111111111111111111111111111111111111111dddddddddddddddddd0000dddddddddd1111111111111111111dd1ddddd111111111111111124221111111111111111111111111111111111111111111111111dddddddddddd
-- 030:ddd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111ddddddddddddddddd0000ddddddddd11111111111111111111111111111111111111111111223221111111111111111111111111111111111111111111111111ddddddddddd
-- 031:dddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddddddddd0000dddddddddd111111111111111111111111111111111111111111122311111111111111111111111111111111111111111111111111dddddddddddd
-- 032:dddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddddddddd0000dddddddddd111111111111111111111111111111111111111111111311111111111111111111111111111111111111111111111111dddddddddddd
-- 033:dddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddddddddd0000dddddddddd111111111111111111111111111111111111111111111211111111111111111111111111111111111111111111111111dddddddddddd
-- 034:dddd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111ddddddddddddddddddd0000dddddddddd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111ddddddddddddd
-- 035:ddddd1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddddddd0000ddddddddddd1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddd
-- 036:ddddd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111ddddddddddddddd0000ddddddddddd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111ddddddddd
-- 037:dddddd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddddd0000dddddddddddd11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddd
-- 038:ddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111d111111111111dddddddddddddd0000ddddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111d111111111111dddddddd
-- 039:ddddddddd1111111111111111111111111111111111111111111111111111111111111111111111111111111111dd11111111111dddddddddddddd0000ddddddddddddddd1111111111111111111111111111111111111111111111111111111111111111111111111111111111dd11111111111dddddddd
-- 040:ddddddddddddd1ddd11111111111111111111111111111111111111111111111111111111111111111111111111d1111111111111ddddddddddddd0000ddddddddddddddddddd1ddd11111111111111111111111111111111111111111111111111111111111111111111111111d1111111111111ddddddd
-- 041:ddddddddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111d11111111111dddddddddddddd0000ddddddddddddddddddddddd111111111111111111111111111111113311111111111111111111111111111111111111111d11111111111dddddddd
-- 042:ddddddddddddddddd11111111111111111111111111111111111111111111111111111111111111111111111111dd11111111111dddddddddddddd0000ddddddddddddddddddddddd11111111111111111111111111111111332111111111111111111111111111111111111111dd11111111111dddddddd
-- 043:ddddddddddddddddd11111111111111111111111111111111111111111111111111111111111111111111111111dd11111111111dddddddddddddd0000ddddddddddddddddddddddd11111111111111111111111111111111233111111111111111111111111111111111111111dd11111111111dddddddd
-- 044:ddddddddddddddddd11111111111111111111111111111111111111111111111111111111111111111111111111ddd111111111ddddddddddddddd0000ddddddddddddddddddddddd11111111111111111111111111111111244211111111111111111111111111111111111111ddd111111111ddddddddd
-- 045:ddddddddddddddddd11111111111111111111111111111111111111111111111111111111111111111111111111d1dd1111111dddddddddddddddd0000ddddddddddddddddddddddd11111111111111111111111111111111244211111111111111111111111111111111111111d1dd1111111dddddddddd
-- 046:ddddddddddddddddd1111111111111111111111111111111111111111111111111111111111111111111111111111111dd1ddddddddddddddddddd0000ddddddddddddddddddddddd1111111111111111111111111111111124221111111111111111111111111111111111111111111dd1ddddddddddddd
-- 047:dddddddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111ddddddddddddddddddddd0000dddddddddddddddddddddd111111111111111111111111111111111232211111111111111111111111111111111111111111111ddddddddddddddd
-- 048:ddddddddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddddddddddddd0000ddddddddddddddddddddddd111111111111111111111111111111122311111111111111111111111111111111111111111111111dddddddddddddd
-- 049:dddddddddddddddd11111111111111111111111111111111111111111111111111111111111111111111111111111111111ddddddddddddddddddd0000dddddddddddddddddddddd11111111111111111111111111111111113111111111111111111111111111111111111111111111111ddddddddddddd
-- 050:ddddddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111ddd1ddddddddddddddd0000ddddddddddddddddddddd111111111111111111111111111111111111211111111111111111111111111111111111111111111111ddd1ddddddddd
-- 051:ddddddddddddddd1111111111111111111111111111111111111111111111111111111111111111111111d111111111111111111111ddddddddddd0000ddddddddddddddddddddd1111111111111111111111111111111111111111111111111111111111111111111111d111111111111111111111ddddd
-- 052:ddddddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddddddddd0000ddddddddddddddddddddd111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111dddd
-- 053:dddddddddddddd11111111111111111111111111111111111110000001111111111111111111111111111111111111111111111111111ddddddddd0000dddddddddddddddddddd11111111111111111111111111111111111112222221111111111111111111111111111111111111111111111111111ddd
-- 054:dddddddddddddd111111111111111111111111111111111100000000000011111111111111111111111111111111111111111111111111dddddddd0000dddddddddddddddddddd111111111111111111111111133333331122222222222211111111111111111111111111111111111111111111111111dd
-- 055:dddddddddddddd1111111111111111111111111111111100000000000000001111111111111111111111111111111111111111111111111ddddddd0000dddddddddddddddddddd1111111111111111111111133333333333222222222222221111111111111111111111111111111111111111111111111d
-- 056:dddddddddddddd1111111111111111111111111111110000000000000000000011111111111111111111111111111111111111111111111ddddddd0000dddddddddddddddddddd1111111111111111111111333333333333322222222222222211111111111111111111111111111111111111111111111d
-- 057:dddddddddddddd1111111111111111111111111111100000000000000000000000111111111111111111111111111111111111111111111ddddddd0000dddddddddddddddddddd1111111111111111111113333333333333332222222222222222111111111111111111111111111111111111111111111d
-- 058:ddddddddddddd11111111111111111111111111110000000000000000000000000001111111111111111111111111111111111111111111eeeeeee0000ddddddddddddddddddd11111111111113331111133333333333333333222222222222222221111111111111111111111111111111111111111111e
-- 059:ddddddddddddd111111111111111111111111111000000000000000000000000000001111111111111111111111111111111111111111111eeeeee0000ddddddddddddddddddd111111111111333331113333333333333333333222222222222222221111111111111111111111111111111111111111111
-- 060:ddddddddddddd11111111111111111111111111000000000000000000000000000000011111111111111111111111111111111111111111eeeeeee0000ddddddddddddddddddd11111111111133333111333333333333333333322222222222222222211111111111111111111111111111111111111111e
-- 061:dddddddddddd111111111111111111111111110000000000000000000000000000000000111111111111111111111111111111111111111eeeeeee0000dddddddddddddddddd111111111111133333113333333333333333333332222222222222222222111111111111111111111111111111111111111e
-- 062:ddddddccccddcccc11cccc11cccc11cccc11cccc00cccc00cccc00cccc00cccc00cccc00cccc11444411444411cccc11cccc11cccc11cccceeeeee0000dddddddddddddddddd111111111111113331113333333333333333333332222222222222222222211111111111111111111111111111111111111e
-- 063:dddddcddddddddddccdddd11ddddccdddd11ddddccdddd00ddddccdddd00ddddccdddd00ddddc4dddd11dddd4cdddd11ddddccdddd11ddddceeeee0000dddddddddddddddddd1111111111111111111133333333333333333332222222222222222222222211111111111111111111111111111111111111
-- 064:dddddcd000c0000dccd00000000dccd00020000dccd00067000dccd00020000dccd00067000dc4d00000000d4cd00000000dccd000c0000dcefefe0000ddddddddddddddddd11111111111111111111133333333333333333322222222222222222222222222111111111111111111111111111111111111
-- 065:dddddcd00ccc000dccd01011010dccd00131000dccd00055000dccd00232000dccd00055000dc4d00011000d4cd01011010dccd00ccc000dcfefef0000ddddddddddddddd1d11111111111111111111133333333333333333222222222222222222222222222211111111111111111111111111111111111
-- 066:dddddcd0ccccc00dccd00123100dccd00232000dccd00055000dccd02343200dccd00055000dc4d00211200d4cd00123100dccd0ccccc00dcefefe0000ddddddddddd11111111111111111111111111133333333333333332222222222222222222222222222222111111111111111111111111111111111
-- 067:dddd111ccccccc01111012223101111002420000000007557000011234c43200000007557000000d322223d1111012223101111ccccccc011fefef0000dddddddddd111111111111111111111111111133333333333333322222222222222222222222222222222211111111111111111111111111111111
-- 068:ddd11110ccccc001111011111101111002420000000065665600211023432000000065665600000d332233d11110111111011110ccccc001ffffff0000ddddddddd1111111111111111111111111111223333333333333322222222222222222222222222222222222111111111111111111111111111111
-- 069:dd111cd00ccc000dccd00123100dccd00232000dccd05655650dccd00232000dccd05655650dc4d01333310d4cd00123100dccd00ccc000dcfffff0000dddddddd11111333334111111111111111112223333333333333322222222222222222222222222222222222211111111111111111111111111111
-- 070:d1111cd000c0000dccd01011010dccd00131000dccd05700750dccd00020000dccd05700750dc4d00011000d4cd01011010dccd000c0000dcfffff0000ddddddd111113333333441111111111111122222333333333333322222222222222222222222222222222222222111111111111111111111111111
-- 071:d1111cd00000000dccd00000000dccd00020000dccd05000050dccd00000000dccd05000050dc4d00000000d4cd00000000dccd00000000dcfffff0000ddddddd111433333333344411111111111222222333333333333322222222222222222222222222222222222222222211111111111111111111111
-- 072:d1111cdddd11ddddccdddd11ddddccdddd00ddddccdddd00ddddccdddd00ddddccdddd00ddddc4dddd00dddd4cdddd00ddddccdddd00ddddc000000000ddddddd114333333333334441111111112222222233333333333332222222222222222222222222222222222222222222222222222222222222222
-- 073:d11111cccc11cccc11cccc11cccc00cccc00cccc00cccc00cccc00cccc00cccc0dcccc00cccc00444400444400cccc00cccc00cccc00cccc0000000000ddddddd114333333333334441111111112222222233333333333332222220222222222222222222222222222222222222222222222222222222222
-- 074:111111111111111111111111110000000000000000000000000000000000dd00d000000000000000000000000000000000000000000000000000000000dddddd1144333333333334444111111122222222222333333333322222220222222222222222222222222222222222222222222222222222222222
-- 075:d1111111111111111111111111000000000000000000000000000000000d0000d000000000000000000000000000000000000000000000000000000000ddddddd144333333333334444111111122222222222222222222232222202022222222222222222222222222222222222222222222222222222222
-- 076:d111111111111111111111111000000000000000000000000000000cccc00cc0d000000000cc0000000000000000000000000000000000000000000000ddddddd444333333333334444411111222222222222222222222332222202022222222222222222222222222222222222222222222222222222222
-- 077:d11111111111111111111111100000000000000000000000000000ccc000ccc0d000000000c0c0c0c00c00cc000cc00000000000000000000000000000ddddddd444433333333344444411111222222222222222222223332222032202222222222222222222222222222222222222222222222222222222
-- 078:1111111111111111111111111000000000000000000000000000dd0ccc000cc00000000000c0c0cc00c0c0c0c0c0c00000000000000000000000000000dddddd1444443333333444444411111222222222222222222233333222033202222222222222222222222222222222222222222222222222222222
-- 079:d1111111111111111111111110000000000000000000000000dd0000ccc00cc00000000000c0c0c000c0c0c0c0cc000000000000000000000000000000ddddddd444444333334444444411111222222222222222222333333330333320222222222222222222222222222222222222222222222222222222
-- 080:d111111111111111111111111000000000000000000000000dddd0cccc00cccc0000000000cc00c0000c00c0c00cc00000000000000000000000000000ddddddd444444444444444444411111222222222222222222333333330333320222222222222222222222222222222222222222222222222222222
-- 081:d1111111111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ddddddd144444444444444444111112222222222222222222333333303333320222222222222222222222222222222222222222222222222222222
-- 082:d11111111111111111111111100000000000000000000000000000000d0000d00000000000000000000000000000000000000000000000000000000000ddddddd144444444444444444111111222222222222222222333333303333322022222222222222222222222222222222222222222222222222222
-- 083:dd11111111111111111111111000000000000000000000000000000000d000d00000000000000000000000000000000000000000000000000000000000dddddddd14444444444444441222111222222222222222222333333033333322022222222222222222222222222222222222222222222222222222
-- 084:dd11111111111111111111111000000000000000000000000000000000d00d00000000000000000cccc0cccc0000000000000000000000000000000000dddddddd14444444444444442222211222222222222222222233333033333222202222222222222222222222222222222222222222222222222222
-- 085:ddd1111111111111111111111000000000000000000000000000000000d00d0000000000000000ccc000000cc000000000000000000000000000000000ddddddddd1444444444444412222211222222222222222222223330333300222202222222222222222222222222222222222222222222222222222
-- 086:dddd1111111111111111111111000000000000000000000000000000000d0d00000000000000000ccc000ccc0000000000000000000000000000000000dddddddddd114444444441112222211122222222222222222222330330022002220222222222222222222222222222222222222222222222222222
-- 087:dddddd11111111111111111111000000000000000000000000000000000d0d000000000000000000ccc0cc000000000000000000000000000000000000dddddddddddd1144444111111222111122222222222222222222203003222220020222222222222222222222222222222222222222222222222222
-- 088:dddddddddd11111111111111111000000000000000000000000000000000d00000000000000000cccc00ccccc011000000000000000000000000000000dddddddddddddddd111111111111111112222222222222222222200222222222200022222222222222222211111111111122222222222222222222
-- 089:dddddddddd11111111111111111100000000000000000000000000000000d0000000000000000100001100000111111000000000000000000000000000dddddddddddddddd111111111111111111222222222222222222022222222222222022222222222222211111111111111111122222222222222222
-- 090:ddddddddd1111111111111111111100000000000000000765cccccccccc567000000000000111111111111111111111ff0000000000000000000000000ddddddddddddddddd11111111111111111122222222222222222765cccccccccc567222222222222111111111111111111111ff222222222222222
-- 091:dddddddddd111111111111111111110000000000000065cccc56700765cccc560000001111111111111111111111111ffff00000000000000000000000ddddddddddddddddd11111111111111111112222222222222265cccc56722765cccc562222221111111111111111111111111ffff2222222222222
-- 092:dddddddddd1111111111111111111ff0000000000005ccc56000000000065ccc500111111111111111111111111111fffffff000000000000000000000dddddddddddddddddd11111111111111111ff2222222222225ccc56222222222265ccc522111111111111111111111111111fffffff22222222222
-- 093:dddddddddd1111111111111111111ffff0000000005cc560000000000000065cc51111111111111111111111111111fffffffff0000000000000000000ddddddddddddddddddd111111111111111fffff2222222225cc562222222222222265cc51111111111111111111111111111fffffffff222222222
-- 094:dddddddddd1111111111111111111ffffff0000000cc50000000000000001115cc111111111111111111111111111efefffffffff00000000000000000dddddddddddddddddddd1111111111111efffffff2222222cc52222222222222221115cc111111111111111111111111111efefffffffff2222222
-- 095:ddddddddddd11111111111111111effffffff00000c5000000000001111111115c11111111111111111111111111efefeffffffffff000000000000000dddddddddddddddddddddd111111111fefeffffffff22222c5222222222221111111115c11111111111111111111111111efefeffffffffff22222
-- 096:ddddddddddd11111111111111111fefeffffffffff000000fffffff1111111111111111111111111111111111111fefefefffffffffff0000000000000dddddddddddddddddddddddeee1eeeeefefefeffffffffff222222fffffff1111111111111111111111111111111111111fefefefffffffffff222
-- 097:dddddddddddd111111111111111fefefefffffffffffffffffffffe1111111111111111111111111111111111111eeefefefeffffffffff00000000000ddddddddddddddddddddddddeeeeeeeeefefefefffffffffffffffffffffe1111111111111111111111111111111111111eeefefefeffffffffff2
-- 098:ddddddddddddd1111111111111eeeefefefefefffffffffffefefefe111111111111111111111111111111111111eeeefefefefffffffffff000000000ddddddddddddddddddddddddeeeeeeeeeeeefefefefefffffffffffefefefe111111111111111111111111111111111111eeeefefefeffffffffff
-- 099:ddddddddddddddd11111111111eeeeefefefefefefefefefefefefeee11111111111111111111111111111111111eeeeefefefeffffffffffffff00000dddddddddddddddddddddddddeeeeeeeeeeeefefefefefefefefefefefefeee11111111111111111111111111111111111eeeeefefefefffffffff
-- 100:ddddddddddddddddd111111111eeeeeeeefefefefefefefefeeeeeeeee111111111111111111111111111111111eeeeeeeeefefefeffffffffffff0000ddddddddddddddddddddddddddeeeeeeeeeeeeeefefefefefefefefeeeeeeeee111111111111111111111111111111111eeeeeeeeefefefeffffff
-- 101:dddddddddddddddddd1111111eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11111111111111111111111111111111eeeeeeeeeeefefefefffffffffff0000dddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee11111111111111111111111111111111eeeeeeeeeeefefefefffff
-- 102:ddddddddddddddddddddd1eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedd111111111111111111111111111111eeeeeeeeeeeefefefeffffffffff0000ddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedd111111111111111111111111111111eeeeeeeeeeeefefefeffff
-- 103:dddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddd1111111111111111111111111111dddeeeeeeeeeeefefefefffffffff0000dddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddd1111111111111111111111111111dddeeeeeeeeeeefefefefff
-- 104:ddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddd11111111111111111111111111dddddeeeeeeeeeeefefefefeffffff0000ddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddd11111111111111111111111111dddddeeeeeeeeeeefefefefe
-- 105:ddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeddddddddddddddd11111111111111111111111ddddddddeeeeeeeeeeefefefefefefff0000ddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeddddddddddddddd11111111111111111111111ddddddddeeeeeeeeeeefefefef
-- 106:dddddddddddddddddddddddddddddeeeeeeeeeeeeeeedddddddddddddddddddd111111111d11111111111ddddddddddeeeeeeeeeeefefefefefefe0000dddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeedddddddddddddddddddd111111111d11111111111ddddddddddeeeeeeeeeeefefefe
-- 107:dddddddddddddddddddddddddddddddeeeeeeeeeedddddddddddddddddddddddd1111111ddddddd1ddddddddddddddddeeeeeeeeeeefefefefefef0000dddddddddddddddddddddddddddddddddddddeeeeeeeeeedddddddddddddddddddddddd1111111ddddddd1ddddddddddddddddeeeeeeeeeeefefef
-- 108:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1dddddddddddddddddddddddddddeeeeeeeeeeeefefefefefe0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd1dddddddddddddddddddddddddddeeeeeeeeeeeefefe
-- 109:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeefefefefef0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeefef
-- 110:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefefefefefe0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefefe
-- 111:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefefefefef0000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefef
-- 112:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeefefefefe0000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeefe
-- 113:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefefefefef0000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefef
-- 114:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeefefefefe0000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeefe
-- 115:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefefefefef0000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefef
-- 116:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeefefefefefe0000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeefefe
-- 117:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefefefefef0000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefef
-- 118:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefefefefefe0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeefefe
-- 119:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeefefefefefef0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeefefef
-- 120:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeefefefefefefe0000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeefefefe
-- 121:ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeefefefefefefef0000ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeefefefef
-- 122:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeefefefefefefefe0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeeefefefefe
-- 123:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefefefffffffef0000dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefefefff
-- 124:dddddddddddddddddddddeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefefffffffffffe0000dddddddddddddddddddddddddddeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefeffffff
-- 125:ddddddddddddddddddeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefefffffffffffff0000ddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefefffffff
-- 126:ddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefeffffffffffffff0000ddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefeffffffff
-- 127:ddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefffffffffffffffff0000ddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefffffffffff
-- 128:dddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefffffff00000000fff0000dddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefffffff22222
-- 129:dddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddeeeeeeeefeffffff000000000000f0000dddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedddddddddddddddddddddddddddddddddddddddddddddeeeeeeeefeffffff2222222
-- 130:ddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefffff0000000000000000000ddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddddeeeeeeeefefffff222222222
-- 131:dddd11111111111111111111111111111111111111111111111111111dddd1111111111111111111111111111111111111111111111111111100000000dddddddddddddddeeeeeeeeeeeeeefefefefefefeeeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddddeeeeeeeefeffff22222222222
-- 132:dddd11111111111111111111111111111111111111111111111111111dddd1111111111111111111111111111111111111111111111111111100000000ddddddddddddddeeeeeeeeeefefefefefefefefefefeeeeeeeeeeeddddddddddddddddddddddddddddddddddddddeeeeeeeefeffff222222222222
-- 133:dddddddeeeeeeeeeefefefefefefefefefefefefeeeeeeeeeedddddddddddddddddddddddddddddddddddeeeeeeeefeffff00000000000000000000000dddddddddddddeeeeeeeeeefefefefefefefefefefefefeeeeeeeeeedddddddddddddddddddddddddddddddddddeeeeeeeefeffff2222222222222
-- 134:ddddddeeeeeeeefefefefefefffffffefefefefefeeeeeeeeeedddddddddddddddddddddddddddddddddeeeeeeeefeffff000000000000000000000000ddddddddddddeeeeeeeefefefefefefffffffefefefefefeeeeeeeeeedddddddddddddddddddddddddddddddddeeeeeeeefeffff22222222222222
-- 135:dddddeeeeeeeefefefefffffffffffffffffffefefeeeeeeeeeedddddddddddddddddddddddddddddddeeeeeeeefeffff0000000000000000000000000dddddddddddeeeeeeeefefefefffffffffffffffffffefefeeeeeeeeeedddddddddddddddddddddddddddddddeeeeeeeefeffff222222222222222
-- </SCREEN>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

