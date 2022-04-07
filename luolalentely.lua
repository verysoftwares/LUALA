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
cam={x=0,y=0}
old_cam={x=0,y=0}	

shots={}

function update()
	--cls(0)
	if not trans then
	line(-old_cam.x+x-cos(a)*8,-old_cam.y+y-sin(a)*8,-old_cam.x+x-cos(a-2*pi/3-0.3)*11,-old_cam.y+y-sin(a-2*pi/3-0.3)*11,0)
	line(-old_cam.x+x-cos(a-2*pi/3-0.3)*11,-old_cam.y+y-sin(a-2*pi/3-0.3)*11,-old_cam.x+x+cos(a)*4,-old_cam.y+y+4*sin(a),0)
	line(-old_cam.x+x+cos(a)*4,-old_cam.y+y+4*sin(a),-old_cam.x+x-cos(a+2*pi/3+0.3)*11,-old_cam.y+y-sin(a+2*pi/3+0.3)*11,0)
	line(-old_cam.x+x-cos(a+2*pi/3+0.3)*11,-old_cam.y+y-sin(a+2*pi/3+0.3)*11,-old_cam.x+x-cos(a)*8,-old_cam.y+y-sin(a)*8,0)
	else trans=nil end
	for bx=x-12,x+12 do for by=y-12,y+12 do
			if pixels[posstr(bx,by)] then
					pix(bx-cam.x,by-cam.y,pixels[posstr(bx,by)])
			end
	end end
	
	dx=0; dy=0; da=0
	if btn(0) then x=x-cos(a); y=y-sin(a); dx=-cos(a); dy=-sin(a) end
	if btn(1) then x=x+cos(a); y=y+sin(a); dx=cos(a); dy=sin(a) end
	if btn(2) then a=a-0.1; da=-0.1 end
	if btn(3) then a=a+0.1; da=0.1 end
	if btnp(4) then ins(shots,{x=x-3,y=y-3,dx=cos(a+pi)*3,dy=sin(a+pi)*3}) end

	y=y+grav
	dy=dy+grav

	--spr(1+t%60//30*2,x,y,14,3,0,0,2,2)
	--print("HELLO WORLD!",84,84)

	for x=0,240*2-1 do for y=136-2,136-1+2 do
		if pixels[posstr(x,y)]==2 then
			pix(x-cam.x,y-cam.y,2+(t*0.2)%3)
		end
	end end
	for x=240-2,240-1+2 do for y=0,136*2-1 do
		if pixels[posstr(x,y)]==2 then
			pix(x-cam.x,y-cam.y,2+(t*0.2)%3)
		end
	end end

	local hit=pix(-cam.x+x,-cam.y+y)
	-- walls
	if hit==13 or hit==14 or hit==15 or oob(x,y) then
			y=y-dy; x=x-dx; --a=a-da
	end
	if hit==2 or hit==3 or hit==4 then
			transition(-cam.x+x,-cam.y+y)
	end
	forcetransition(-cam.x+x,-cam.y+y)
	
	local points={--{-cam.x+x-cos(a)*8,-cam.y+y-sin(a)*8},
	              {-cam.x+x-cos(a-2*pi/3-0.3)*11,-cam.y+y-sin(a-2*pi/3-0.3)*11},
															--{-cam.x+x+cos(a)*4,-cam.y+y+4*sin(a)},
															{-cam.x+x-cos(a+2*pi/3+0.3)*11,-cam.y+y-sin(a+2*pi/3+0.3)*11}}	
	for i,v in ipairs(points) do
	-- base
	local hit=pix(v[1],v[2])
	if hit==5 or hit==6 or hit==7 or hit==12 then
			y=y-dy; x=x-dx; a=a-da
			break
	end

	end
	
	for i=#shots,1,-1 do
			local sh=shots[i]
			if sh.oldpos then
					for lx=0,7 do for ly=0,7 do
							--if sprpix(32,lx,ly)~=0 then
									local p=pixels[posstr(sh.oldpos.x+lx,sh.oldpos.y+ly)]
									if not p then
											pix(-old_cam.x+sh.oldpos.x+lx,-old_cam.y+sh.oldpos.y+ly,0)
									else pix(-old_cam.x+sh.oldpos.x+lx,-old_cam.y+sh.oldpos.y+ly,p) end
							--end
					end end
			end
	end
	for i=#shots,1,-1 do
			local sh=shots[i]
			sh.x=sh.x+sh.dx; sh.y=sh.y+sh.dy
			sh.oldpos={x=sh.x,y=sh.y}
			local hit=false
			for lx=0,7 do for ly=0,7 do
					if sprpix(32,lx,ly)~=0 and is_solid(pixels[posstr(sh.x+lx,sh.y+ly)]) then
							pix(-cam.x+sh.x+lx,-cam.y+sh.y+ly,1)
							pixels[posstr(sh.x+lx,sh.y+ly)]=1
							hit=true
					end
			end end
			if not hit then
			spr(32,sh.x-cam.x,sh.y-cam.y,0)
			else rem(shots,i) end
	end

	points={{-cam.x+x-cos(a)*8,-cam.y+y-sin(a)*8},
         {-cam.x+x-cos(a-2*pi/3-0.3)*11,-cam.y+y-sin(a-2*pi/3-0.3)*11},
									{-cam.x+x+cos(a)*4,-cam.y+y+4*sin(a)},
									{-cam.x+x-cos(a+2*pi/3+0.3)*11,-cam.y+y-sin(a+2*pi/3+0.3)*11}}
	old_cam={x=cam.x, y=cam.y}	
	--[[for i,v in ipairs(points) do
			if pix(v[1],v[2])==2 then
					transition(v[1],v[2])
					break
			end
	end]]
	if not trans then
	for i,v in ipairs(points) do
			if i<#points then
			line(v[1],v[2],points[i+1][1],points[i+1][2],13)
			else
			line(v[1],v[2],points[1][1],points[1][2],13)
			end
	end
	end
	--cam.x=x-240/2; cam.y=y-136/2

	t=t+1
end

pixels={}
local seed=89828907--math.random(120948087)
trace(seed)

function load()
		cls(0)
		px,py=px or 0,py or 0

		if py==136*2-1 then
				cls(0)
				for x=0,240-1 do for y=0,136-1 do
						if pixels[posstr(x,y)] then
								pix(x,y,pixels[posstr(x,y)])
						end
				end end				
				::attempt::
				local rx,ry=math.random(0,240-1),math.random(0,136-1)
				while pixels[posstr(rx,ry)] do
				rx,ry=math.random(0,240-1),math.random(0,136-1)
				end
				while not pixels[posstr(rx,ry)] do
				ry=ry+1
				end
				if pixels[posstr(rx,ry)]==2 or oob(rx,ry-16) or is_solid(pixels[posstr(rx,ry-16)]) then trace('bad spawn, rerolling'); goto attempt end
				spr(64,rx-12,ry-6,0,1,0,0,3,1)
				for x=rx-12,rx+12 do for y=ry-6,ry do
				if pix(x,y)~=0 then pixels[posstr(x,y)]=pix(x,y) end
				end end
				x=rx; y=ry-16
				TIC=update; trace('Generation complete.')
				return
		end
		
		for x=px,math.min(px+64,240*2-1) do for y=py,math.min(py+64,136*2-1) do 
			if (y>=134 and y<136) or (y>=136 and y<138) or (x>=238 and x<240) or (x>=240 and x<242) then pixels[posstr(x,y)]=2 end
			if perlin(x*0.015,y*0.015,seed)>0.45 then
					pixels[posstr(x,y)]=15
					--pix(x,y,14)
			end		
			if perlin(x*0.015,y*0.015,seed)>0.5 then
					pixels[posstr(x,y)]=14
					--pix(x,y,14)
			end
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

TIC=load

function transition(tx,ty)
		if ty>=134 and ty<136 and dy>0 then
				cam.y=cam.y+136
				trans=true
		end
		if ty>=0 and ty<2 and dy<0 then
				cam.y=cam.y-136
				trans=true
		end
		if tx>=238 and tx<240 and dx>0 then
				cam.x=cam.x+240
				trans=true
		end
		if tx>=0 and tx<2 and dx<0 then
				cam.x=cam.x-240
				trans=true
		end
		if trans then
				cls(0)
				for x=cam.x,cam.x+240-1 do for y=cam.y,cam.y+136-1 do
						local p=pixels[posstr(x,y)]
						if p then
								pix(x-cam.x,y-cam.y,p)
						end
				end end
		end
end

function forcetransition(tx,ty)
		if ty>=136 and dy>0 then
				cam.y=cam.y+136
				trans=true
		end
		if ty<0 and dy<0 then
				cam.y=cam.y-136
				trans=true
		end
		if tx>=240 and dx>0 then
				cam.x=cam.x+240
				trans=true
		end
		if tx<0 and dx<0 then
				cam.x=cam.x-240
				trans=true
		end
		if trans then
				cls(0)
				for x=cam.x,cam.x+240-1 do for y=cam.y,cam.y+136-1 do
						local p=pixels[posstr(x,y)]
						if p then
								pix(x-cam.x,y-cam.y,p)
						end
				end end
		end
end

function oob(x,y)
		return x<0 or y<0 or x>=240*2 or y>=136*2
end

function is_solid(px)
		return px==13 or px==14 or px==15
end

-- my lua implementation of Perlin noise
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

