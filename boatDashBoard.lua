COLORS = {
    background = {0, 11, 21},
    border     = {0, 7, 16},
    highlight  = {150, 150, 205, 140},
    blue       = {0, 13, 34},
    blackblue  = {0, 13, 20},
    blackRed   = {86, 7, 12},
    blackYellow= {126,82,0}
}

-- Tick function that will be executed every logic tick
function onTick()
	value = input.getNumber(1)			 -- Read the first number from the script's composite input
	
	compass =  (input.getNumber(2)+0.5)*360
	compass = compass // 1
	centerX = 48
	
	currentPosFront = (input.getNumber(4)+0.5)*360
	currentPosLeft  = (input.getNumber(5)+0.5)*360	
	currentPosRight = (input.getNumber(6)+0.5)*360
	power = input.getNumber(7)
	boilerTemp = 96 .. "º"
	furnaceTemp = 117 .. "º"
	bool = input.getBool(1)
end
	
local axV, ayV, bxV, byV, cxV, cyV = 0, 0, 0, 0, 0, 0
local dxV, dyV, exV, eyV, fxV, fyV = 0, 0, 0, 0, 0, 0
local gxV, gyV, hxV, hyV, ixV, iyV = 0, 0, 0, 0, 0, 0


function setColor(c)
    screen.setColor(c[1], c[2], c[3], c[4] or 255)
end

function dist(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function trianguloValido(ax, ay, bx, by, cx, cy, epsilon)
    local ab = dist(ax, ay, bx, by)
    local bc = dist(bx, by, cx, cy)
    local ca = dist(cx, cy, ax, ay)

    return math.abs(ab - bc) <= epsilon
       and math.abs(bc - ca) <= epsilon
       and math.abs(ca - ab) <= epsilon
end

local function calcularTriangulo(cx, cy, ang, comprimento, meiaBase)
    local rad = math.rad(ang)

    -- ponta do triângulo
    local ax = cx
    local ay = cy
    -- centro da base
    local mx = cx + math.cos(rad) * comprimento
    local my = cy + math.sin(rad) * comprimento
    -- vetor perpendicular
    local px = -math.sin(rad)
    local py =  math.cos(rad)
    -- pontas da base
    local bx = mx + px * meiaBase
    local by = my + py * meiaBase

    local cx2 = mx - px * meiaBase
    local cy2 = my - py * meiaBase

    -- arredonda pra pixels
    return
        math.floor(ax + 0.5), math.floor(ay + 0.5),
        math.floor(bx + 0.5), math.floor(by + 0.5),
        math.floor(cx2 + 0.5), math.floor(cy2 + 0.5)
end

function drawGauge(power, x, y, height, width, color, text)
	setColor(COLORS.background)	
	screen.drawRectF(x, y-height, width, height)
	
	setColor(color)
	local bar = (power*height)
	screen.drawRectF(x, y, width, -bar)

	setColor(COLORS.blue)
	screen.drawTextBox(x, y-height, width, height, text, 0, 0)
	
	setColor(COLORS.border)
	screen.drawRect(x, y-height, width, height)
	
end

function drawButton(bool, x, y, height, width, color, color2, color3, text)
	if bool then
		setColor(color2)
	else
		setColor(color3)
	end
	screen.drawRectF(x, y, width, height)
	
	if not bool then
		setColor(color2)
	else
		setColor(color)
	end
	screen.drawTextBox(x, y, width, height, text, 0, 0)
	
	setColor(COLORS.border)
	screen.drawRect(x, y, width, height)
end

function drawnTextBox(var, x, y, width, height, color1, color2, color3, text)
	local line = (height-2)/2
	setColor(color2)
	screen.drawRectF(x, y, width, height)
	setColor(color1)
	screen.drawTextBox(x, y+1, width, line, text, 0, 0)
	screen.drawTextBox(x, y+line+1, width, line, var, 0, 0)
	setColor(color3)
	screen.drawRect(x, y, width, height)
end

-- Draw function that will be executed when this script renders to a screen
function onDraw()
	w = screen.getWidth()				  -- Get the screen's width and height
	h = screen.getHeight()
	setColor(COLORS.blue)
	screen.drawRectF(0, 0, 96, 64)
	setColor(COLORS.blackblue)
	screen.drawRectF(25, 0, 46, 64)
	
	--AXIS
	local axisFrontx, axisFronty = 48, 21
	local axisLeftx, axisRightx = 38, 58
	local axisReary = 47
	local circleDiameter = 9
	setColor(COLORS.background)	
	screen.drawCircleF(axisFrontx, axisFronty, circleDiameter)
	screen.drawCircleF(axisLeftx, axisReary, circleDiameter)
	screen.drawCircleF(axisRightx, axisReary, circleDiameter)
	setColor(COLORS.border)
	screen.drawCircle(axisFrontx, axisFronty, circleDiameter)
	screen.drawCircle(axisLeftx, axisReary, circleDiameter)
	screen.drawCircle(axisRightx, axisReary, circleDiameter)
	setColor(COLORS.highlight)
	
    -- Parâmetros dos triângulos
    local comprimento = 7
	local meiaBase = 4
	local epsilon = 0.3
	
	--Axis Front
	local ax, ay, bx, by, cx, cy =
	    calcularTriangulo(axisFrontx, axisFronty, currentPosFront, comprimento, meiaBase)
	
	if trianguloValido(ax, ay, bx, by, cx, cy, epsilon) then
    	axV, ayV, bxV, byV, cxV, cyV = ax, ay, bx, by, cx, cy
	end
	screen.drawTriangleF(axV, ayV, bxV, byV, cxV, cyV)
	
	--Axis Rear Left
	local dx, dy, ex, ey, fx, fy =
	calcularTriangulo(axisLeftx, axisReary, currentPosLeft, comprimento, meiaBase)
	
	if trianguloValido(dx, dy, ex, ey, fx, fy, epsilon) then
    	dxV, dyV, exV, eyV, fxV, fyV = dx, dy, ex, ey, fx, fy
	end
	screen.drawTriangleF(dxV, dyV, exV, eyV, fxV, fyV)
	
	--Axis Rear Right
	local gx, gy, hx, hy, ix, iy =
	calcularTriangulo(axisRightx, axisReary, currentPosRight, comprimento, meiaBase)
	
	if trianguloValido(gx, gy, hx, hy, ix, iy, epsilon) then
    	gxV, gyV, hxV, hyV, ixV, iyV = gx, gy, hx, hy, ix, iy
	end
	screen.drawTriangleF(gxV, gyV, hxV, hyV, ixV, iyV)


	--COMPASS
	setColor(COLORS.border)
	screen.drawRect(25, 0, 46, 4)
	setColor(COLORS.background)
	screen.drawRectF(39, 3, 20, 7)
	setColor(COLORS.border)
	screen.drawRect(39, 3, 20, 7)
	setColor(COLORS.background)
	screen.drawRectF(25, 0, 46, 4)
	setColor(COLORS.highlight)
    --screen.drawRect(39, 4, 20, 6)
    for x = 26, 71, 4 do
        -- Aplica deslocamento
        local drawX = x - compass % 4
        -- Distância ao centro
        local dist = math.abs(drawX - centerX)
        -- Define altura
        local height
        if dist <= 1 then
            height = 3
        elseif dist <= 8 then
            height = 2
        else
            height = 1
        end
        if drawX>=25 then
        	screen.drawLine(drawX, 0, drawX, height)
        end
    end
	screen.drawTextBox(27, 4, 45, 5, math.floor(compass) .. "º", 0, 0)
	
	
	--SPEED
	screen.drawTextBox(25, 58, 45, 5, math.floor(value) .. "m/s", 0, 0)
	
	--Labels
	setColor(COLORS.blue)	
	screen.drawRectF(0, 0, 25, 64)
	screen.drawRectF(71, 0, 25, 64)
	setColor(COLORS.border)		
	screen.drawLine(25, 0, 25, 64)
	screen.drawLine(71, 0, 71, 64)
	
	--Right low Label
	--Throttle
	drawGauge(power, 74, 62, 25, 8, COLORS.highlight, "THR")
	--Button backwards
	drawButton(bool, 85, 55, 7, 8, COLORS.highlight, COLORS.blackRed, COLORS.background, "R")
	--Button second gear
	drawButton(bool, 85, 46, 7, 8, COLORS.background, COLORS.highlight, COLORS.background, "2")
	--Button first gear
	drawButton(bool, 85, 37, 7, 8, COLORS.background, COLORS.highlight, COLORS.background, "1")
	--TextBox Boiler
	drawnTextBox(boilerTemp, 71, 18, 25, 14, COLORS.highlight, COLORS.background, COLORS.border, "BT:  ")
	--TextBox Furnace
	drawnTextBox(furnaceTemp, 0, 18, 25, 14, COLORS.highlight, COLORS.background, COLORS.border, "FT:  ")
	
	
	--Left low Label
	drawGauge(power, 2, 62, 25, 8, COLORS.highlight, "GAS")
	--Battery
	drawGauge(power, 13, 62, 25, 8, COLORS.highlight, "BAT")
	


end