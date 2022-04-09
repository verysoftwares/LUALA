-- title:  LUALA
-- author: verysoftwares
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
		
		for j=1,#ships do
		clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
		UIdraw(j)
		end
	
		for j=#ships,1,-1 do
				local s=ships[j]
				if s.gone then 
				rem(ships,j); rem(cams,j); rem(old_cams,j) 
				
				for j2,s2 in ipairs(ships) do
				local cam=cams[j2]
				clip(cam.ax,cam.ay,cam.aw,cam.ah)
				line(cam.ax-cam.x+s.x-cos(s.a)*8,cam.ay-cam.y+s.y-sin(s.a)*8,cam.ax-cam.x+s.x-cos(s.a-2*pi/3-0.3)*11,cam.ay-cam.y+s.y-sin(s.a-2*pi/3-0.3)*11,0)
				line(cam.ax-cam.x+s.x-cos(s.a-2*pi/3-0.3)*11,cam.ay-cam.y+s.y-sin(s.a-2*pi/3-0.3)*11,cam.ax-cam.x+s.x+cos(s.a)*4,cam.ay-cam.y+s.y+4*sin(s.a),0)
				line(cam.ax-cam.x+s.x+cos(s.a)*4,cam.ay-cam.y+s.y+4*sin(s.a),cam.ax-cam.x+s.x-cos(s.a+2*pi/3+0.3)*11,cam.ay-cam.y+s.y-sin(s.a+2*pi/3+0.3)*11,0)
				line(cam.ax-cam.x+s.x-cos(s.a+2*pi/3+0.3)*11,cam.ay-cam.y+s.y-sin(s.a+2*pi/3+0.3)*11,cam.ax-cam.x+s.x-cos(s.a)*8,cam.ay-cam.y+s.y-sin(s.a)*8,0)
				end

				end
		end
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
												{sx=240,sy=0,ax=240/2-2-(240/2-2)/2,ay=136/2+2,aw=240/2-2,ah=136/2-2}}
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

		local rw=s.hp/30*(cam.aw-8)
		for x=cam.ax+4,cam.ax+4+rw do for y=cam.ay+cam.ah-1-4,cam.ay+cam.ah-1-4+2 do
				local p=pixels[posstr(x-cam.ax+cam.x,y-cam.ay+cam.y)]
				if p then
						pix(x,y,p)
				else pix(x,y,0) end
		end end
		end
end

function shipprocess(j)
		local s=ships[j]
		local cam=cams[j]
		local old_cam=old_cams[j]

		--s.oldx=s.x; s.oldy=s.y		
		s.dx=0; s.dy=0; s.da=0
		if btn((s.id-1)*8) then s.x=s.x-cos(s.a); s.y=s.y-sin(s.a); s.dx=-cos(s.a); s.dy=-sin(s.a) end
		if btn((s.id-1)*8+1) then s.x=s.x+cos(s.a); s.y=s.y+sin(s.a); s.dx=cos(s.a); s.dy=sin(s.a) end
		if btn((s.id-1)*8+2) then s.a=s.a-0.1; s.da=-0.1 end
		if btn((s.id-1)*8+3) then s.a=s.a+0.1; s.da=0.1 end
		if btnp((s.id-1)*8+4) then ins(shots,{x=s.x-3,y=s.y-3,dx=cos(s.a+pi)*3,dy=sin(s.a+pi)*3,owner=s}) end
	
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
		
		local points={--{-cam.sx+s.x-cos(s.a)*8,-cam.sy+s.y-sin(s.a)*8},
		              {s.x-cos(s.a-2*pi/3-0.3)*11,s.y-sin(s.a-2*pi/3-0.3)*11},
																--{-cam.sx+x+cos(a)*4,-cam.sy+y+4*sin(a)},
																{s.x-cos(s.a+2*pi/3+0.3)*11,s.y-sin(s.a+2*pi/3+0.3)*11}}	
		for i,v in ipairs(points) do
		-- base
		local hit=pix(cam.ax+v[1]-cam.x,cam.ay+v[2]-cam.y)
		if hit==5 or hit==6 or hit==7 or hit==12 then
				s.y=s.y-s.dy; s.x=s.x-s.dx; s.a=s.a-s.da
				if not s.healing then
				s.healing=t
				s.oldx=s.x; s.oldy=s.y
				end
				break
		end
	
		end
		
		if s.healing then 
				if (t-s.healing)%12==0 then
				s.hp=s.hp+1
				if s.hp>30 then s.hp=30 end
				end
				if math.floor(s.oldy)~=math.floor(s.y) or math.floor(s.oldx)~=math.floor(s.x) then
						s.healing=nil
				end
		end

		--old_cams[j]={sx=cam.sx, sy=cam.sy, x=cam.x, y=cam.y}
end

function environprocess()
		-- flashing transitions
		
		local trc=2+(t*0.2)%4
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
				
		for i=#shots,1,-1 do
				local sh=shots[i]
				if sh.oldpos then
						for lx=0,7 do for ly=0,7 do
								--if sprpix(32,lx,ly)~=0 then
										local p=pixels[posstr(sh.oldpos.x+lx,sh.oldpos.y+ly)]

										for j,s in ipairs(ships) do
										clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
										if not p then
												pix(cams[j].ax-cams[j].x+math.floor(sh.oldpos.x+lx),cams[j].ay-cams[j].y+math.floor(sh.oldpos.y+ly),0)
										else pix(cams[j].ax-cams[j].x+sh.oldpos.x+lx,cams[j].ay-cams[j].y+sh.oldpos.y+ly,p) end
										end
										clip()
								--end
						end end
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
				if wallhits<=4 then
				for j,s in ipairs(ships) do
				clip(cams[j].ax,cams[j].ay,cams[j].aw,cams[j].ah)
				spr(32,cams[j].ax+sh.x-cams[j].x,cams[j].ay+sh.y-cams[j].y,0)
				end
				clip()
				else rem(shots,i) end
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
												pix(cams[j2].ax-cams[j2].x+sh.x+lx,cams[j2].ay-cams[j2].y+sh.y+ly,0) 
										end
								end end
						end
						clip()
						dmg(j,s)
						rem(shots,i)
						break
				end
				end
				end
		end
end

function dmg(j,s)
		s.hp=s.hp-3
		if s.hp<=0 then s.gone=true end
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
		for i,v in ipairs(points) do
				if i<#points then
				line(cam.ax+v[1]-cam.x,cam.ay+v[2]-cam.y,cam.ax+points[i+1][1]-cam.x,cam.ay+points[i+1][2]-cam.y,13)
				else
				line(cam.ax+v[1]-cam.x,cam.ay+v[2]-cam.y,cam.ax+points[1][1]-cam.x,cam.ay+points[1][2]-cam.y,13)
				end
		end
		end
		
		end
end

function UIdraw(j)
		
		local s=ships[j]
		local cam=cams[j]

		local rw=s.hp/30*(cam.aw-8)
		rect(cam.ax+4,cam.ay+cam.ah-1-4,rw,2,6)
		
end

pixels={}
local seed=math.random(120948087)--89828907
trace(seed)

function load()
		cls(0)
		px,py=px or 0,py or 0

		if py==136*2-1 then
				cls(0)

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
			if perlin(x*0.015,y*0.015,seed)>0.45 then
					pixels[posstr(x,y)]=15
			end
			if perlin(x*0.015,y*0.015,seed)>0.475 then
					if (x+y)%2==0 then pixels[posstr(x,y)]=15
					else pixels[posstr(x,y)]=14 end
			end
			if perlin(x*0.015,y*0.015,seed)>0.5 then
					pixels[posstr(x,y)]=14
			end
			--[[if perlin(x*0.015,y*0.015,seed)>0.525 then
					if (x+y)%2==0 then pixels[posstr(x,y)]=14
					else pixels[posstr(x,y)]=13 end
			end]]
			if perlin(x*0.015,y*0.015,seed)>0.55 then
					pixels[posstr(x,y)]=13
					--pix(x,y,14)
			end		
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
		return newship
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
		if ty>=134 and ty<136 and s.dy>0 then
				cams[j].sy=cams[j].sy+136
				s.trans=true
		end
		if ty>=0 and ty<2 and s.dy<0 then
				cams[j].sy=cams[j].sy-136
				s.trans=true
		end
		if tx>=238 and tx<240 and s.dx>0 then
				cams[j].sx=cams[j].sx+240
				s.trans=true
		end
		if tx>=0 and tx<2 and s.dx<0 then
				cams[j].sx=cams[j].sx-240
				s.trans=true
		end
		if s.trans then
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
				renderwindow(j)
		end
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
-- 035:2222222222222222222222222222222222222222222222222222222222222222
-- 051:2222222222222222222222222222222222222222222222222222222222222222
-- 064:00000000000000000000765c0065cccc05ccc5605cc56000cc500000c5000000
-- 065:0000000000000000cccccccc5670076500000000000000000000000000000000
-- 066:0000000000000000c5670000cccc5600065ccc5000065cc5000005cc0000005c
-- 067:2222222222222222222222222222222222222222222222222222222222222222
-- 080:2222222222222222222222222222222222222222222222222222222222222222
-- 081:2222222222222222222222222222222222222222222222222222222222222222
-- 082:2222222222222222222222222222222222222222222222222222222222222222
-- 083:2222222222222222222222222222222222222222222222222222222222222222
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

