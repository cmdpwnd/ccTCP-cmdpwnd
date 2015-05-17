--[[License

The MIT License (MIT)

Copyright (c) 2015 ccTCP Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

--]]

local sides = {"top","bottom","left","right","back","front"}
local sidesTable = {top = 0,bottom = 1,left = 2,right = 3,back = 4,front = 5}
local modem = {}
local defaultSide = ""
local channel  = 20613

function wrap()
	for a = 1,6 do 
		if peripheral.isPresent(sides[a]) then 
			if peripheral.getType(sides[a]) == "wireless_modem" or peripheral.getType(sides[a]) == "modem" then
				if defaultSide == "" then defaultSide = sides[a] end
				modem[sides[a]] = peripheral.wrap(sides[a])
			end
		end
		a = a+1
	end
end

function intOpen(int)
	modem[int].open(channel)
end

function intClose(int)
	modem[int].close()
end

function send(int,data)
	local frame = standFrame or QFrame
	if (not data == nil) then 
		modem[int or defaultSide].transmit(channel,channel,data)
	else
		modem[int or defaultSide].transmit(channel,channel,frame)
		standFrame = standFrame_Temp
		QFrame = QFrame_Temp
	end
end

function receive()
	while true do
		local event = {os.pullEvent("modem_message")}
		if event[3] == channel then
			local destMac = string.sub(event[5],1,6)
			local sendMac = string.sub(event[5],7,12)
			if destMac == Ethernet.getMac(event[2]) then
				return event[5], event[2]
			end
		end
	end
end
---
---
---

local macTable = {}

---
---
---

function DecToBase(val,base)
	local b,k,result,d=base or 10, "0123456789ABCDEFGHIJKLMNOPQRSTUVW",""
	while val>0 do
		val,d=math.floor(val/b),math.fmod(val,b)+1
		result=string.sub(k,d,d)..result
	end
	return result
end

function toDec(val,base)
	return tonumber(val,base)
end

function crc(msg)
	local buffer = {msg:byte(1,#msg)}
	local add = 0
	for i,v in pairs(buffer) do
		add = add + v
	end
	return string.rep("0",5-#tostring(DecToBase(add,16)))..tostring(DecToBase(add,16))
end

config = {}

config.dir = "ccTCP/"
function config.macBindings()

end