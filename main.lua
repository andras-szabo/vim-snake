function reset()
	local ptr = snake.head
	repeat
		board[snake[ptr].x][snake[ptr].y]=nil
		ptr = snake[ptr].nxt
	until ptr == nil
	snake.size = 1
	snake.head = 1
	snake.tail = 1
	snake[1].prv = nil
	snake[1].nxt = nil
	snake.growing = 5
end

function newFood()
	repeat
		food.x = love.math.random(1, screenSizeX / pixSizeX)
		food.y = love.math.random(1, screenSizeY / pixSizeY)
	until board[food.x][food.y] == nil
	board[food.x][food.y] = "food"	
end

function love.load()
	snake = {}
	snake.dir = "right"
	snake.speed = 20 	-- blocks per second
	snake.desiredDir = "right"
	snake.head = 1		-- index of the snake's head
	snake.tail = 1		-- index of the snake's tail
	snake.growing = 5	-- will decrement upon growing additional segment
	snake.size = 1
	snake[1] = {}
	snake[1].prv = nil
	snake[1].nxt = nil
	snake[1].x = 20
	snake[1].y = 20
	timer = 0

	pixSizeX = 10
	pixSizeY = 10
	screenSizeX = 800
	screenSizeY = 600

	board = {}
	for i = 0, screenSizeX / pixSizeX do
		board[i] = {}
	end

	board[snake[1].x][snake[1].y]="snake"
	food = {}
	newFood()
end

function love.update(dt)
	local right = love.keyboard.isDown("l")
	local left = love.keyboard.isDown("h")
	local up = love.keyboard.isDown("k")
	local down = love.keyboard.isDown("j")

	if snake.dir == "right" or snake.dir == "left" then
		if up == true then snake.desiredDir = "up"
		elseif down == true then snake.desiredDir = "down" end
	elseif snake.dir == "up" or snake.dir == "down" then
		if left == true then snake.desiredDir ="left"
		elseif right == true then snake.desiredDir = "right" end
	end

	timer = timer + dt

	if timer >= 1.0 / snake.speed then
		timer = 0
		snake.dir = snake.desiredDir

		local xmod = 0
		local ymod = 0

		if snake.dir == "right" then
				xmod = 1
		elseif snake.dir == "left" then
				xmod = -1
		elseif snake.dir == "up" then
				ymod = -1
		else
			ymod = 1
		end
		
		if snake.growing > 0 then
			snake.growing = snake.growing - 1
			snake.size = snake.size + 1
			
			-- create new segment, set it as head

			snake[snake.size] = {}
			snake[snake.size].x = snake[snake.head].x + xmod
			snake[snake.size].y = snake[snake.head].y + ymod

			if snake[snake.size].x > screenSizeX / pixSizeX then
				snake[snake.size].x = 0
			elseif snake[snake.size].x < 0 then
				snake[snake.size].x = screenSizeX / pixSizeX
			end

			if snake[snake.size].y > screenSizeY / pixSizeY then
				snake[snake.size].y = 0
			elseif snake[snake.size].y < 0 then
				snake[snake.size].y = screenSizeY / pixSizeY
			end

			snake[snake.size].nxt = snake.head
			snake[snake.size].prv = nil

			-- adjust head

			snake[snake.head].prv = snake.size

			snake.head = snake.size
		else
			-- Not growing: adjust tail to become new head.
			local newtail = snake[snake.tail].prv
			snake[newtail].nxt = nil
	
			board[snake[snake.tail].x][snake[snake.tail].y]=nil

			snake[snake.tail].x = snake[snake.head].x + xmod
			snake[snake.tail].y = snake[snake.head].y + ymod
			
			if snake[snake.tail].x > screenSizeX / pixSizeX then
				snake[snake.tail].x = 0
			elseif snake[snake.tail].x < 0 then
				snake[snake.tail].x = screenSizeX / pixSizeX
			end

			if snake[snake.tail].y > screenSizeY / pixSizeY then
				snake[snake.tail].y = 0
			elseif snake[snake.tail].y < 0 then
				snake[snake.tail].y = screenSizeY / pixSizeY
			end

			snake[snake.tail].nxt = snake.head
			snake[snake.tail].prv = nil

			snake[snake.head].prv = snake.tail
			snake.head = snake.tail
			snake.tail = newtail
		end

		if board[snake[snake.head].x][snake[snake.head].y] == "snake" then
			reset()
		elseif board[snake[snake.head].x][snake[snake.head].y] == "food" then
			snake.growing = snake.growing + 5
			board[snake[snake.head].x][snake[snake.head].y] = "snake"
			newFood()
		end 
		board[snake[snake.head].x][snake[snake.head].y] = "snake"
	end
end

function love.draw()
	love.graphics.setColor(120, 255, 255, 255)
	
	ptr = snake.head

	repeat
		local posx = snake[ptr].x * pixSizeX
		local posy = snake[ptr].y * pixSizeY

		love.graphics.rectangle("fill", posx, posy, pixSizeX, pixSizeY)

		ptr = snake[ptr].nxt
	until ptr == nil

	love.graphics.setColor(255,100,100,255)
	love.graphics.rectangle("fill", food.x * pixSizeX, food.y * pixSizeY, pixSizeX, pixSizeY)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
end
