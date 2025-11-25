local socket	= require "socket"

local address	= "mini.xkeeper.net"
local port		= "37800"
local rate		= 1/60

local oldTimer	= 0
local timer		= 0
local packetN	= 0
local packetT	= {}
local packetC	= {}
local packetH	= 120 * 90 * 1

local soundD	= math.ceil(1 / rate) * 2
local soundN	= 0
local lastPing	= 0
local lastPingY = nil
local lastPingDrawn	= false
local font		= nil

function love.load(args)

	for i = 1, #args do --kenko: added args ability
		if args[i]:find("^-a=") ~= nil then
			address = string.sub(args[i], 4);
		end
		if args[i]:find("^-p=") ~= nil then
			port = string.sub(args[i], 4);
		end
		if args[i]:find("^-r=") ~= nil then
			rate = 1 / tonumber(string.sub(args[i], 4));
		end
	end

	font			= love.graphics.newFont("XFont.ttf", 16, "mono");

	thr			= love.thread.newThread("thread.lua")
	thr:start()

	ch			= love.thread.getChannel("args")
	ch:push(address)
	ch:push(port)
	ch:push(rate)

	udp			= socket.udp()
	udp:settimeout(0)
	udp:setpeername(address, port)

end

function love.update(dt)
	doCheck()

	while ((soundD + soundN) < packetN) do
		soundN	= soundN + 1

		if soundN > 0 then
			if packetT[soundN][1] then
				local tD	= packetT[soundN][2]
				lastPing	= tD
			else
				lastPing	= false
			end
		end
	end
end

failColor	= {1, 0, 0}

function love.draw()
	love.graphics.setFont(font);

	local sX	= 120
	local sY	= 90
	local sW	= 8
	local sH	= 8
	local sP	= 0

	local tn	= math.ceil((packetN - packetH + 2) / sX) * sX
	local xP	= 0
	local yP	= 0
	for i = 0, packetH - 1 do
		xP	= (i % sX) * sW + sP
		yP	= math.floor(i / sX) * sH + sP

		local pI	= tn + i

		if packetT[pI] then

			if packetC[pI] then
				love.graphics.setColor(packetC[pI])

			--elseif packetC[pI] and packetC[pI].fail then
			--	love.graphics.setColor(failColor)

			elseif not packetC[pI] then
				local tV	= packetT[pI][2] - love.timer.getTime()
				local col	= pingToColor(tV)
				if tV < -2.5 then
					packetC[pI]	= failColor
				end
				love.graphics.setColor(col)
			end

		elseif tn+i == packetN + 1 then
			love.graphics.setColor(1, 1, 1)

		elseif tn+i > packetN then
			love.graphics.setColor(0.05, 0.05, 0.05)
		else
			love.graphics.setColor(0.3, 0.3, 0.3)
		end

		love.graphics.rectangle("fill", xP, yP, sW, sH)

		if pI == soundN then
			love.graphics.setColor(1, 1, 1)
			love.graphics.rectangle("line", xP + 1, yP + 1, sW - 2, sH - 2)
		end

	end

	failColor[2]	= (math.sin(love.timer.getTime() * 6)) * 0.5 + 0.5
	failColor[3]	= failColor[2]


	gY	= 680

	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Response Time", 1080, 10)
	lastPingDrawn = false
	doGraph(0.000, 0.100, 0.0005)
	gY	= gY + 1
	doGraph(0.100, 0.250, 0.0005)
	gY	= gY + 1
	doGraph(0.250, 2.001, 0.012501) --kenko: janked this just so the top numbers are rounded :)))

end


function doGraph(st, max, step)
	local nP	= 0
	for i = st, max, step do
		love.graphics.setColor(pingToColor(i))
		love.graphics.rectangle("fill", 1100, gY, 10, 1)


		if (not lastPingDrawn and lastPing and lastPing < i) then
			if not lastPingY then
				lastPingY = gY
			end
			lastPingY = lastPingY * 0.9 + gY * 0.1 - 0.2
			local lastPingYD	= math.ceil(lastPingY)

			love.graphics.print(string.format("       >"), 997, gY - 10)
			love.graphics.print(string.format("       >"), 996, gY - 11)

			love.graphics.print(string.format("%4dms", lastPing * 1000), 997, lastPingYD - 10)
			love.graphics.print(string.format("%4dms", lastPing * 1000), 996, lastPingYD - 11)
			love.graphics.setColor(1, 1, 1)
			love.graphics.print(string.format("       >"), 995, gY - 12)
			love.graphics.print(string.format("%4dms", lastPing * 1000), 995, lastPingYD - 12)
			lastPingDrawn	= true
		end
		if nP % 20 == 0 then
			love.graphics.setColor(1, 1, 1)
			love.graphics.print(string.format("- %4dms", i * 1000), 1110, gY - 12)
		end



		gY		= gY - 1
		nP		= nP + 1
	end
end


function cs(v)
	return math.max(0, math.min(1, v))
end

function sv(v, m)
	return cs(v / m)
end



function printColor(c)
	return string.format("%.2f %.2f %.2f", c[1], c[2], c[3])
end

function pingToColor(v)
	if v < -2.5 then
		return { 1, 0, 0 }

	elseif v < -0.5 then
		local tv = math.abs(v) - 0.5
		return { 1, cs(1 - tv / 2), cs(1 - tv / 2) }

	elseif v <= 0 then
		return { 1, 1, 1 }

	elseif v < 0.100 then
		local min = 0
		local max = 0.1
		local pct = (v - min) / (max - min)
		return { 0, cs(pct), 0 }
	
	elseif v < 0.250 then
		local min = 0.1
		local max = 0.25
		local pct = (v - min) / (max - min)
	
		local t = v - 0.100
		local margin = t / 0.100
	
		return { 1, cs(1 - pct), cs(pct * 0.4) }
	
	else
		local min = 0.25
		local max = 2.5
		local pct = (v - min) / (max - min)

		return { 0.7 + cs(pct) / 0.3, cs(pct), 1 }
	
	end
end



function doCheck()
	while true do
		local tmp	= ch:pop()
		if not tmp then
			return
		end
		if not tmp[3] then
			-- new packet
			packetN	= tmp[1];
			packetT[packetN]	= {false, tmp[2]}
			packetC[packetN]	= nil
			packetT[packetN - packetH] = nil
			packetC[packetN - packetH] = nil

		else
			if packetT[tmp[1]] then
				-- ok
				packetT[tmp[1]]	= {true, tmp[2] - packetT[tmp[1]][2]}
				local tx	= packetT[tmp[1]][2]
				packetC[tmp[1]] = pingToColor(tx)
			end

		end
	end
end