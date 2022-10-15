--- DO NOT LOAD THIS MODULE!!!
--- It is intended for internal use ONLY!

local g = {
	os = os,
	io = io,
	require = require,
	pairs = pairs,
	ipairs = ipairs,
	setmetatable = setmetatable,
}

local capi = {
	---@type screen
	screen = screen,
	---@type mouse
	mouse = mouse,
	awesome = awesome,
}

local awful = g.require("awful")
local wibox = g.require("wibox")
local gears = g.require("gears")
local beautiful = g.require("beautiful")
local menubar_utils = g.require("menubar").utils
wibox.layout.overflow = g.require("wibox_layout_overflow")

local lgi = g.require("lgi")
local Gio = lgi.Gio

local util = g.require("desktop_icons.util")

-- TODO: Get rid of this
local launcher_utils = g.require("modules.widgets.rasti_launcher.utils")

local desktop_dir = util.get_desktop_dir()

local generators = { builtin = {}, file = {} }

---@class desktop_icons.peeker : wibox

---@class desktop_icons.peeker.grid : wibox.layout.grid
---@field try_add fun(self)
---@field save_layout fun(self)

---@return desktop_icons.peeker
function generators.create_dir_peeker(args)
	args = util.default(args, {})
	args.style = util.default(args.style, {})
	args.style.orientation = util.default(args.style.orientation--[[ , "vertical" ]], "horizontal")
	args.style.container = util.default(args.style.container, {})
	args.style.container.title = util.default(args.style.container, {})
	args.style.container.title.font  = util.default(args.style.container.title.font,  "Sans, Bold 12")
	args.style.container.title.align = util.default(args.style.container.title.align, "center")
	args.style.container.geometry = util.default(args.style.container.geometry, {})
	-- The width and height are set automatically based on the shortcut amount, shortcut geometry and wanted line count
	--args.style.container.geometry.width  = util.default(args.style.container.geometry.width,  util.scale(500))
	--args.style.container.geometry.height = util.default(args.style.container.geometry.height, util.scale(320))
	args.style.container.geometry.line_count = util.default(args.style.container.geometry.line_count, 3)
	args.style.container.geometry.max_length = util.default(args.style.container.geometry.max_length, util.scale(500)) -- direction is orientation dependent
	args.style.container.geometry.min_cols_size = util.default(args.style.container.geometry.min_cols_size, util.scale(50))
	args.style.container.geometry.min_rows_size = util.default(args.style.container.geometry.min_rows_size, util.scale(50))
	args.style.container.geometry.grid_spacing = util.default(args.style.container.geometry.grid_spacing, util.scale(10))
	args.style.container.shape = util.default(args.style.container.shape, function(cr, w, h) gears.shape.rounded_rect(cr, w, h, 20) end)
	args.style.container.bg = util.default(args.style.container.bg, beautiful.bg_normal, "#202020")
	args.style.container.fg = util.default(args.style.container.fg, beautiful.fg_normal, "#E0E0E0")
	args.style.shortcut = util.default(args.style.shortcut, {})
	args.style.shortcut.geometry = util.default(args.style.shortcut.geometry, {})
	args.style.shortcut.geometry.width = util.default(args.style.shortcut.geometry.width, util.scale(140))
	args.style.shortcut.geometry.height = util.default(args.style.shortcut.geometry.height, util.scale(90))

	--button_width  = util.scale(140)
	--button_height = util.scale(90)

	local path = desktop_dir.."/"..args.file

	---@type desktop_icons.peeker
	local peeker = wibox {
		--width = args.style.container.geometry.width,
		--height = args.style.container.geometry.height,
		visible = false,
		ontop = false,
	}

	---@type desktop_icons.peeker.grid
	local grid = wibox.widget {
		homogeneous     = true,
		expand          = false,
		orientation     = args.style.orientation,
		spacing         = args.style.container.geometry.grid_spacing,
		min_cols_size   = args.style.container.geometry.min_cols_size,
		min_rows_size   = args.style.container.geometry.min_rows_size,
		forced_num_rows = 3,
		forced_height   = peeker.height,
		layout          = wibox.layout.grid,
	}

	function grid:try_add(shortcut)
		if not shortcut then
			return
		end

		self:add(shortcut)
	end

	peeker.widget = wibox.widget {
		{
			grid,
			--{
			--	text = "Realize into history car. Smile for act trial. Defense tax new people avoid over.\nNumber mean direction discussion the present past. Set sport current issue be.\nDevelopment see much situation floor. Hospital course yourself forward hand even. Onto improve hair me success card.\nSport your capital clearly his often growth. Hold arrive ground why war almost. Skill least listen.\nInstitution thank rate fish while make. Not grow we war these thing. Yet prevent near impact bag degree.\nTree medical us program. Drive available decade factor.\nToday know public enter seat. Give standard edge most save loss.\nWhy capital move. Bill gas capital think.\nDark turn significant shake low. Dream toward weight real important animal. Himself day enter our spring.\nExample show site coach back option modern. Difficult data brother hit maybe task. Final accept memory market none develop government.\nYes foreign each son modern.\nCare parent beautiful single start side. Open nothing have individual usually.\nParent white until pretty citizen main notice morning. Senior whether stand music occur control.\nKid media class both although whether including. Day ahead eye well plant type.\nClaim keep live body. President amount shoulder example scene information. Performance person message per to assume.\nNote week social technology by keep. Suffer decision stuff.\nArea talk open protect TV first life lose. Together pressure let.\nRight concern message simple. Response information road health walk. Building like end specific impact huge again. Forward edge nearly despite stand toward.\nKitchen music very think central when. Head after current pull.\nExperience it yet news figure. Support film war design line turn.\nFine hospital peace shoulder them beyond cup. Public age begin artist operation.\nArrive machine public heavy glass outside language.\nPublic enter professor dark structure. Stay action role people play leave.\nEstablish industry month Congress space drive. And suffer actually future pretty positive turn. Tend they term population hair.\nTreat bed entire.\nBig now remember plant character rock. Cold sister purpose. Team different debate future be strong term. Commercial book strategy factor.\nUnder resource seek election. Know away consumer minute company name.\nBag identify win serve again. House nor analysis production.\nRate space run across. Put current reach.\nInformation myself onto rock rock hospital way. Bad month artist court other from read account. Debate interesting country stand.\nBody just increase site. Make fast most security.\nAlmost rather tonight city region. Service face catch know do million PM. Soldier interesting experience red month student.\nSmile Democrat Republican social form. Subject sport sing wind success. Child east late since people husband draw.\nEat drive visit growth include rather experience.\nRelationship spring ball national free several. Area see factor product. Music hear hot enjoy expert market.\nSpeak step goal. Child thank image catch sound security record election. Series south other election minute international.\nPeople between sea community. Amount kitchen reveal responsibility practice. Company smile report expect blue line my.\nHotel lay maintain condition old. Give score answer every.\nFive prove seat in. Tree base new sell. Hour decide candidate stage method.\nRock enough official computer prove main. Seat adult worry citizen girl. Get program property decade protect become house may.\nWrong surface last ever present. Experience smile often. Site course probably at.\nWorker rule reach enter side wait. Where deep yet road.\nForce scene out spring people way.\nAble list true friend reduce parent. Green our area message eat. Practice art point nearly.\nGeneration late operation though report. Statement environment door. Read generation whether song defense.\nLeft adult sense born.\nDetail far down line practice natural. End partner author board. Professor stand later figure themselves red.\nDecade mission professional line increase at live. Month opportunity no nice green improve. Popular politics president writer require bring number for.\nSeries lawyer every they rise. Commercial lay simple present. Service now benefit generation discussion age for down.\nPeople approach court standard number western college detail.\nWhether million camera. Describe price production even TV quality local citizen. Scene arrive beat consider value partner continue.\nGeneral collection first argue. Cell then type move defense. Water take boy.\nData name together sound leader unit. Room usually total source entire board.\nAmong network forward reveal instead cost fire. Almost story choice customer child do.\nData group eight matter realize arrive hard usually. Down authority herself natural. Size rate carry fall likely significant concern.\nSuggest however clear sound federal necessary future. General here structure near use.\nCarry chair together travel marriage simple. Behavior out edge money yourself.\nIssue edge best simply collection street. Song woman break question even week.\nFilm available respond source. Subject short without collection.\nManager voice relationship already parent worry. Live these effort position source west.\nJoin none remain read. No city respond notice go it likely. Sound car continue value.\nNational political feeling side image leader. Young traditional rest for stay politics letter. Save idea when such meeting thank. Major street teacher position type any knowledge.\nBaby season way history down every. Find season provide them employee.\nSociety expect shake possible plant. Kid investment ten floor any industry animal little. Piece provide yourself decade against growth plan.\nUnder seem feel sea. Voice home cost seem. Budget pick suddenly detail.\nCommon street him sound college possible. Girl direction more list.\nClaim low develop model. Project more understand not list.\nDifficult but likely as interesting. Thank subject situation quickly present way. Trouble focus including maintain audience agent identify.\nAssume wrong after shoulder. Once put deal than work another. Population itself late section common.\nBig entire hour beat start interesting. Anything record keep upon discussion billion. Focus deep health entire particularly check.\nOption the miss situation artist about. Tree available class star professor sit. Serious do light friend wall store. Himself open picture win cut year religious.\nDetermine detail pattern high foreign though. Grow less hospital industry. Support government role tree enjoy tough establish.\nSave majority fast gun four local. Point we you long nation middle. Everybody week carry technology feeling.\nVisit smile mean suggest billion. Image must book system among inside read decide. However upon only especially card commercial.\nNature magazine want of next forget. Head wrong wall agent heavy visit conference cell.\nPoor experience something southern magazine president. Movie system program summer those take serious. Goal cost may who machine music. Like strategy answer again its despite according.\nSecurity leave major care method drug region. Scene late reflect hour cut another Democrat these.\nPresent near happen. Rather ability probably media state with.\nHope near network adult. However key resource mention seven.\nSister rich stage attention it someone seek. Later impact energy method approach top. Serve discussion study center anyone subject candidate six.\nNever operation now probably.\nPicture industry thing public city task. Off weight its maintain story. Necessary officer top already me there.\nDemocrat possible admit big office picture. Away happen cause different explain wait lawyer address. How save best build tough learn.\nHave others effect evening assume choose. Keep sing amount forward challenge wear film. Local Mr couple recognize sing set.\nWould purpose thus southern money. Box various structure. Reveal crime pretty play because sign.\nOut write because information sell relationship. Bit each big woman staff suggest pay cold. Look week move attention yet rise respond.\nRule save mean. Official boy expert some. Star ground thus then girl. Play security reveal far.\nHave night trade protect right contain. Development player worker expert.\nBed direction once standard. Common able technology memory lawyer.\nFather surface over learn thus plan civil. Under crime design something. Whatever able employee still.\nSimilar they clear product.\nHer run individual enough federal woman. Best discuss candidate perform exist minute.\nLine often treat everybody like affect. Some soldier know student staff left prove.\nOrder old follow. Voice huge often wind from everything. Eye read subject culture could usually then.\nInterview option war like very police down carry. National property reflect help live per maintain.\nRule democratic interesting trade member responsibility sense. Clear hotel final city least. Explain simply entire green eight.\nMost dinner modern many wrong whatever. Of visit be from cover. My man pretty kid raise.\nManagement check success marriage deal business. Voice serious probably example message subject. Eight lot will form machine.\nArticle likely open city officer war.\nFear fish shake do hand feeling. Why dark avoid teacher. Every rest choose too apply job. Board standard letter sea.\nEven model such hospital policy out behind. Suddenly fund sell traditional manager player.\nPm poor all just.\nAbility focus TV somebody increase. So consider where say.\nOwn hotel which entire expert little. Where voice spring she sit final. Clear performance mention matter.\nSkill issue rich eat already field level. Decide on effect safe leg account western. Agreement thing team conference.\nMember stage out dog visit. Agency never try low environment peace. Officer continue enjoy four.\nForget game blood radio. Agreement mean station grow instead kid. Soldier action through behind avoid lot. Church this fact cause seek national.\nStuff one population son. Tree century ok war.",
			--	widget = wibox.widget.textbox,
			--},
			margins = util.scale(5),
			widget = wibox.container.margin,
		},
		layout = wibox.layout.overflow[args.style.orientation],
	}

	function peeker:update_geometry()
		local lc = args.style.container.geometry.line_count
		--self.forced_num_rows = self.forced_num_rows or 1
		if args.style.orientation == "horizontal" then
			self.width = args.style.container.geometry.max_length
			self.height = args.style.shortcut.geometry.height * lc + args.style.container.geometry.grid_spacing * (lc + 1)

			do
				local height = args.style.shortcut.geometry.height
				local i = 1
				while height * i < self.height do
					i = i + 1
				end
				i = i - 1 --- Prevent overshooting
				grid.forced_num_rows = i

				if #grid.children < i then --- The widget is smaller than it needs to be - shrink it
					self.height = args.style.shortcut.geometry.height * #grid.children + args.style.container.geometry.grid_spacing * (#grid.children + 1)

					local width = args.style.shortcut.geometry.width * lc + args.style.container.geometry.grid_spacing * (lc + 1)
					local needed_width = args.style.shortcut.geometry.width * #grid.children + args.style.container.geometry.grid_spacing * (#grid.children + 1)
					if needed_width < args.style.container.geometry.max_length then
						self.width = needed_width
					end
				end
			end
		else -- vertical
			self.width = args.style.shortcut.geometry.width * lc + args.style.container.geometry.grid_spacing * (lc + 1)
			self.height = args.style.container.geometry.max_length

			do
				local width = args.style.shortcut.geometry.width
				local i = 1
				while width * i < self.width do
					i = i + 1
				end
				i = i - 1 --- Prevent overshooting
				grid.forced_num_cols = i

				if #grid.children < i then --- The widget is smaller than it needs to be - shrink it
					self.width = args.style.shortcut.geometry.width * #grid.children + args.style.container.geometry.grid_spacing * (#grid.children + 1)

					local height = args.style.shortcut.geometry.height * lc + args.style.container.geometry.grid_spacing * (lc + 1)
					local needed_height = args.style.shortcut.geometry.height * #grid.children + args.style.container.geometry.grid_spacing * (#grid.children + 1)
					if needed_height < args.style.container.geometry.max_length then
						self.height = needed_height
					end
				end
			end
		end
		grid:emit_signal("widget::layout_changed")
		grid:emit_signal("widget::redraw_needed")
	end

	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			--local f = desktop_dir_path.."/"..file
			local f = path.."/"..file
			--- TODO: Try use the settings from `main()` for args
			grid:try_add(generators.file {
				--grid, {
				--	show_files = true,
				--	show_desktop_launchers = true,
				--}, f, false, file,
				parrent = grid,
				screen = args.screen,
				file = file,
				file_path = f,
				is_for_desktop = false,
				show_files = true,
				show_desktop_launchers = true,
				geo = args.geo,
				state = args.state,
			})
		end
	end

	peeker:update_geometry()

	local cursor_is_above = false

	peeker:connect_signal("mouse::enter", function()
		cursor_is_above = true
	end)

	peeker:connect_signal("mouse::leave", function()
		cursor_is_above = false
		peeker.visible = false
	end)

	capi.awesome.connect_signal("desktop_icons::hide_all_peekers", function()
		peeker.visible = false
	end)

	capi.awesome.connect_signal("desktop_icons::hide_all_peekers_except", function(p)
		if p ~= peeker then
			peeker.visible = false
		end
	end)

	function peeker:cursor_is_above()
		return cursor_is_above
	end

	return peeker
end


---@class desktop_icons.desktop_shortcut

---@class desktop_icons.desktop_shortcut._args.onclick
---@field [1] nil|fun(args: desktop_icons.desktop_shortcut._args|nil): bool|nil Called on primary (left) mouse button click
---@field [2] nil|fun(args: desktop_icons.desktop_shortcut._args|nil): bool|nil Called on middle mouse button (mouse wheel) click
---@field [3] nil|fun(args: desktop_icons.desktop_shortcut._args|nil): bool|nil Called on secondary (right) mouse button click; if not set, a right click menu will be added
---@field [4] nil|fun(args: desktop_icons.desktop_shortcut._args|nil): bool|nil Called when scrolling up
---@field [5] nil|fun(args: desktop_icons.desktop_shortcut._args|nil): bool|nil Called when scrolling down

---@class desktop_icons.desktop_shortcut._args
---@field parrent wibox.layout.grid --- Required; Used to be `args.grid`
---@field is_for_desktop bool|nil Default: `true`; If false, features like dnd or peeking will be disabled
---@field icon str|cairo.ImageSurface|nil Default: `beautiful.awesome_icon`
---@field label str|nil Default: `"Placeholder"`
---@field font str|nil Default: `beautiful.desktop_icon_font` **or** `beautiful.font`
---@field onclick desktop_icons.desktop_shortcut._args.onclick|nil
---@field type "builtin"|"desktop"|"file"|"directory"|nil Default: `"file"`
---@field tooltip str|nil Default: *(value of `args.label`)*
---@field id str|nil Default: *(value of `args.label`)*
---@field desktop_dir str|nil Default: *(value of `get_desktop_dir()` as returned by module `desktop_icons.get_desktop_dir`)*

---@param args desktop_icons.desktop_shortcut._args
---@return desktop_icons.desktop_shortcut new_shortcut
function generators.create_shortcut_widget(args)
	args = util.default(args, {})
	args.parrent   = args.parrent --- required
	args.is_for_desktop = util.default(args.is_for_desktop, true)
	--args.screen         = util.default(args.screen, capi.screen.primary) --- deprecated in favor of `mouse.screen`
	args.icon    = util.default(args.icon, beautiful.awesome_icon)
	args.label   = util.default(args.label, "Placeholder")
	args.font    = util.default(args.font, beautiful.desktop_icon_font, beautiful.font)
	args.type    = util.default(args.type, "file")
	args.tooltip = util.default(args.tooltip, args.label)
	args.id      = util.default(args.id, args.label)
	args.onclick = args.onclick
	args.desktop_dir = util.default(args.desktop_dir, desktop_dir)

	--notifyf("%s -> %s", args.id, args.parrent)

	local current_holder = args.parrent

	local widget_geo = {
		width = util.scale(140),
		height = util.scale(90),
	}

	local widget_icon = wibox.widget {
		image = args.icon,
		forced_height = util.scale(60),
		halign = "center",
		widget = wibox.widget.imagebox,
	}

	local widget_label = wibox.widget {
		text = args.label,
		font = args.font,
		align = "center",
		forced_height = util.scale(30),
		widget = wibox.widget.textbox,
	}

	local widget = wibox.widget {
		{
			{
				nil,
				widget_icon,
				widget_label,
				forced_width = widget_geo.width,
				forced_height = widget_geo.height,
				layout = wibox.layout.align.vertical,
			},
			halign = "center",
			valign = "center",
			layout = wibox.container.place,
		},
		bg = gears.color.transparent,
		shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(5)) end,
		shape_border_width = util.scale(1),
		shape_border_color = gears.color.transparent,
		widget = wibox.container.background,
	}

	--[[
	local tooltip = awful.tooltip {
		objects = { widget },
		timeout = 1,
		timer_function = function()
			if state.is_holding_icon then
				return ""
			end

			return args.tooltip
		end,
	}
	--]]

	local menu_items = {
		{ "Open", args.onclick[1] },
		-- { "Open with..." },
		--{ "Copy" },
		--{ "Cut" },
	}

	if args.type == "file" or args.type == "directory" then
		table.insert(menu_items, { "Move to trash", function()
			awful.spawn { "trash", desktop_dir.."/"..args.id }
		end })
	end

	local menu = awful.menu {
		items = menu_items,
	}

	if args.type == "directory" and args.is_for_desktop then
		--widget.peeker = generators.create_dir_peeker(args)
		widget.peeker = generators.create_dir_peeker({
			screen = args.screen,
			geo = args.geo,
			state = args.state,
			file = args.id,
		})
	end

	local old_cursor, old_wibox
	widget:connect_signal("mouse::enter", function(w)
		args.state.is_over_icon = true

		local wb = mouse.current_wibox or {}
		old_cursor, old_wibox = wb.cursor, wb
		wb.cursor = "hand1"

		w.bg = "#50A0C040"
		w.shape_border_color = "#50A0C0B0"

		if w.peeker then
			capi.awesome.emit_signal("desktop_icons::hide_all_peekers_except", w.peeker)
			local cur_w_geo = mouse.current_widget_geometry
			w.peeker.is_showable = true
			gears.timer {
				timeout = 0.5,
				autostart = true,
				callback = function(self)
					if not w.peeker.is_showable then
						self:stop()
						return
					end

					w.peeker.visible = true
					w.peeker.x = cur_w_geo.x + cur_w_geo.width-util.scale(20)
					w.peeker.y = cur_w_geo.y + cur_w_geo.height-util.scale(20)
					awful.placement.no_offscreen(w.peeker, {
						honor_workarea = true,
						screen = mouse.screen,
					})
					self:stop()
				end,
			}
		end
	end)

	widget:connect_signal("mouse::leave", function(w)
		args.state.is_over_icon = false

		if old_wibox then
			old_wibox.cursor = old_cursor
			old_wibox = nil
		end

		w.bg = gears.color.transparent
		w.shape_border_color = gears.color.transparent

		if w.peeker then
			w.peeker.is_showable = false
			if mouse.current_wibox == w.peeker then
				capi.awesome.emit_signal("desktop_icons::hide_all_peekers_except", w.peeker)
			else
				capi.awesome.emit_signal("desktop_icons::hide_all_peekers")
			end
		end
	end)

	if args.is_for_desktop then
		widget:connect_signal("button::press", function(w,_,_,b)
			args.state.is_holding_icon = true

			local wb = mouse.current_wibox or {}
			if b == 1 then
				w.bg = "#80C0E080"
				w.shape_border_color = "#A0D0F0D0"
				wb.cursor = "fleur" -- fleur
			end

			args.state.holding_start_pos = mouse.coords()

			if not mousegrabber.isrunning() then
				widget.floating_dnd_box = wibox {
					type    = "dnd",
					width   = args.geo.button_width,
					height  = args.geo.button_height,
					bg      = gears.color.transparent,
					visible = false,
					ontop   = true,
					opacity = 0.75,
					widget  = {
						widget,
						bg = "#80C0E080",
						shape = function(cr, w, h) gears.shape.rounded_rect(cr, w, h, util.scale(5)) end,
						shape_border_width = util.scale(1),
						shape_border_color = "#A0D0F0D0",
						widget = wibox.container.background
					},
				}
				widget.floating_dnd_box_was_placed = false

				mousegrabber.run(function(mouse_state) ---@param mouse_state { x: int, y: int, buttons: bool[] }
					if not widget.floating_dnd_box_was_placed then
						widget.floating_dnd_box_was_placed = true
						widget.floating_dnd_box.x = mouse_state.x - widget.floating_dnd_box.width/2
						widget.floating_dnd_box.y = mouse_state.y - widget.floating_dnd_box.height/2
					end

					if (math.abs(mouse_state.x - args.state.holding_start_pos.x) > 10
						or math.abs(mouse_state.x - args.state.holding_start_pos.x) < -10
						or math.abs(mouse_state.y - args.state.holding_start_pos.y) > 10
						or math.abs(mouse_state.y - args.state.holding_start_pos.y) < -10)
						and mouse_state.buttons[1]
					then
						widget.floating_dnd_box.visible = true
						widget.floating_dnd_box.x = mouse_state.x - widget.floating_dnd_box.width/2
						widget.floating_dnd_box.y = mouse_state.y - widget.floating_dnd_box.height/2
						w.bg = gears.color.transparent
						w.shape_border_color = gears.color.transparent
						capi.awesome.emit_signal("desktop_icons::hide_all_peekers")
					end

					if not mouse_state.buttons[1] then
						args.state.is_holding_icon = false

						if b == 1 then
							w.bg = "#50A0C040"
							w.shape_border_color = "#50A0C0B0"

							if widget.floating_dnd_box.visible then
								widget.floating_dnd_box.visible = false

								-- desktop_grid:get_widget_position(widget) -> { col, row, col_span, row_span }
								local new_holder = current_holder
								for _, w_below in pairs(mouse.current_widgets) do
									if w_below._is_desktop_grid then
										new_holder = w_below
										break
									end
								end

								local old_pos = current_holder:get_widget_position(widget)
								local new_pos = new_holder:get_tile_index_at_coords(mouse_state.x, mouse_state.y)

								if (old_pos.row ~= new_pos.row or old_pos.col ~= new_pos.col) and new_holder:get_widgets_at(new_pos.row, new_pos.col, 1, 1) == nil then
									current_holder:remove_widgets_at(old_pos.row, old_pos.col, 1, 1)
									new_holder:add_widget_at(widget, new_pos.row, new_pos.col, 1, 1)
									current_holder = new_holder
									args.state.save_layout()
								else
									local clear_bg = true
									for _, widget_under_cursor in pairs(mouse.current_widgets) do
										if w == widget_under_cursor then
											clear_bg = false
											break
										end
									end
									if clear_bg then
										w.bg = gears.color.transparent
										w.shape_border_color = gears.color.transparent
									else
										mousegrabber.stop()
									end
								end
							else
								args.onclick[b]()
							end
							mousegrabber.stop()
						elseif b == 3 then
							mousegrabber.stop()
							menu:toggle()
						end
					end

					return mouse_state.buttons[1]
				end, wb.cursor or "fleur")
			end
		end)
	else
		widget:connect_signal("button::press", function(w,_,_,b)
			args.state.is_holding_icon = true

			local wb = mouse.current_wibox or {}
			if b == 1 then
				w.bg = "#80C0E080"
				w.shape_border_color = "#A0D0F0D0"
			end
		end)

		widget:connect_signal("button::release", function(w,_,_,b)
			args.state.is_holding_icon = false

			w.bg = "#50A0C040"
			w.shape_border_color = "#50A0C0B0"

			args.onclick[b]()
		end)
	end

	function widget:get_icon()
		return widget_label:get_image()
	end
	function widget:set_icon(path)
		widget_icon:set_image(path)
	end

	function widget:get_label()
		return widget_label:get_text()
	end
	function widget:set_label(label)
		widget_label:set_text(label)
	end

	function widget:get_savedata()
		return {
			type = args.type,
			id = args.id,
		}
	end

	return widget
end

function generators.builtin.home(args)
	if not args.show then
		return
	end

	local desktop_icon = generators.create_shortcut_widget {
		parrent = args.parrent,
		icon = "/usr/share/icons/Papirus-Dark/24x24/places/user-home.svg",
		label = "Home",
		type = "builtin",
		id = "home",
		screen = args.screen,
		geo = args.geo,
		state = args.state,
		is_for_desktop = args.is_for_desktop,
		onclick = {
			function()
				awful.spawn.with_shell("xdg-open "..g.os.getenv("HOME"))
			end,
		},
	}

	return desktop_icon
end

function generators.builtin.computer(args)
	if not args.show then
		return
	end

	local desktop_icon = generators.create_shortcut_widget {
		parrent = args.parrent,
		icon = "/usr/share/icons/Papirus-Dark/24x24/places/user-desktop.svg",
		label = "Your Computer",
		type = "builtin",
		id = "computer",
		screen = args.screen,
		geo = args.geo,
		state = args.state,
		is_for_desktop = args.is_for_desktop,
		onclick = {
			function()
				awful.spawn.with_shell("xdg-open /")
			end,
		},
	}

	return desktop_icon
end

function generators.builtin.trash(args)
	if not args.show then
		return
	end

	local trash_path = g.os.getenv("HOME").."/.local/share/Trash/files"
	local trash_path_esc = trash_path:gsub('\'', [['"'"']])
	local icon_empty, icon_filled = "/usr/share/icons/Papirus-Dark/24x24/places/user-trash.svg", "/usr/share/icons/Papirus-Dark/24x24/places/user-trash-full.svg"
	local label_empty, label_filled = "Trash", "Trash (filled)"

	local desktop_icon = generators.create_shortcut_widget {
		parrent = args.parrent,
		icon = icon_empty,
		label = "Trash",
		type = "builtin",
		id = "trash",
		screen = args.screen,
		geo = args.geo,
		state = args.state,
		is_for_desktop = args.is_for_desktop,
		onclick = {
			function()
				awful.spawn { "gio", "trash:///" }
			end,
		},
	}

	local function update()
		awful.spawn.easy_async({ "ls", "-A", trash_path }, function(stdout, stderr, reason, exit_code)
			if stdout == "" then
				desktop_icon:set_icon(icon_empty)
				desktop_icon:set_label(label_empty)
				return
			end

			desktop_icon:set_icon(icon_filled)
			desktop_icon:set_label(label_filled)
		end)
	end
	update()

	awful.spawn.with_line_callback("inotifywait --monitor '"..trash_path_esc.."'", {
		stdout = function(line)
			update()
		end,
	})

	return desktop_icon
end

function generators.builtin.web_browser(args)
	if not args.show then
		return
	end

	local desktop_icon = generators.create_shortcut_widget {
		parrent = args.parrent,
		icon = "/usr/share/icons/Papirus-Dark/24x24/categories/internet-web-browser.svg",
		label = "Web Browser",
		type = "builtin",
		id = "web_browser",
		screen = args.screen,
		geo = args.geo,
		state = args.state,
		is_for_desktop = args.is_for_desktop,
		onclick = {
			function()
				awful.spawn.with_shell("xdg-open http://")
			end,
		},
	}

	return desktop_icon
end

function generators.builtin.terminal(args)
	if not args.show then
		return
	end

	local desktop_icon = generators.create_shortcut_widget {
		parrent = args.parrent,
		icon = "/usr/share/icons/Papirus-Dark/24x24/categories/terminal.svg",
		label = "Terminal",
		type = "builtin",
		id = "terminal",
		screen = args.screen,
		geo = args.geo,
		state = args.state,
		is_for_desktop = args.is_for_desktop,
		onclick = {
			function()
				awful.spawn.with_shell(util.default(args.terminal_emulator, terminal, "xterm"))
			end,
		},
	}

	return desktop_icon
end

-- -@param args {parrent: wibox.layout.grid, file_name: str, full_path: str, draggable: bool}

function generators.file.desktop(args)
	local desktop_file = Gio.DesktopAppInfo.new_from_filename(args.file_path)
	--local desktop_file = launcher_utils.parse_desktop_file(path)
	--if not desktop_file.IconPath or desktop_file.IconPath == "" or not util.file_exists(desktop_file.IconPath) then
	--	desktop_file.IconPath = "/usr/share/icons/Papirus-Dark/24x24/apps/x.svg"
	--end
	local name = desktop_file:get_locale_string("Name")

	local icon_path
	for _, icon_name in g.ipairs(desktop_file:get_icon():get_names()) do
		icon_path = menubar_utils.lookup_icon(icon_name) or ("/usr/share/icons/Papirus-Dark/24x24/apps/"..icon_name..".svg")
		if icon_path ~= nil then
			break
		end
	end

	local desktop_icon = generators.create_shortcut_widget {
		parrent = args.parrent,
		icon = icon_path,
		label = name,
		type = "desktop",
		id = args.file,
		screen = args.screen,
		geo = args.geo,
		state = args.state,
		is_for_desktop = args.is_for_desktop,
		onclick = {
			function()
				awful.spawn.with_shell(desktop_file.Cmdline)
			end,
		},
	}

	return desktop_icon
end

function generators.file.directory(args)
	local desktop_icon = generators.create_shortcut_widget {
		parrent = args.parrent,
		icon = "/usr/share/icons/Papirus-Dark/24x24/places/folder.svg",
		label = args.file,
		type = "directory",
		screen = args.screen,
		geo = args.geo,
		state = args.state,
		is_for_desktop = args.is_for_desktop,
		onclick = {
			function()
				awful.spawn { "xdg-open", args.file_path }
			end,
		},
	}

	return desktop_icon
end

function generators.file.document(args)
	local desktop_icon = generators.create_shortcut_widget {
		parrent = args.parrent,
		icon = "/usr/share/icons/Papirus-Dark/24x24/mimetypes/application-x-zerosize.svg",
		label = args.file,
		type = "file",
		screen = args.screen,
		geo = args.geo,
		state = args.state,
		is_for_desktop = args.is_for_desktop,
		onclick = {
			function()
				awful.spawn { "xdg-open", args.file_path }
			end,
		},
	}

	if util.file_can_be_cairo_surface(args.file_path) then
		desktop_icon:set_icon(args.file_path)
	else
		util.get_mime_type(args.file_path, function(mime_type)
			local icon = "/usr/share/icons/Papirus-Dark/24x24/mimetypes/application-x-zerosize.svg"
			if mime_type then
				icon = "/usr/share/icons/Papirus-Dark/24x24/mimetypes/"..mime_type..".svg"
			end

			desktop_icon:set_icon(icon)
		end, true)
	end

	return desktop_icon
end

setmetatable(generators.file, {
	--__call = function(self, desktop_grid, args, file, is_for_desktop, label)
	__call = function(self, args)
		if not args.file or (not args.show_hidden_files and args.file:match("^%.")) then
			return
		end

		args.label = args.label or args.file

		--args.file_path = args.file
		if not (args.file_path and args.file_path:match("^/")) then
			args.file_path = desktop_dir.."/"..args.file
		end

		if gears.filesystem.is_dir(args.file_path) then
			if args.show_files then

				--return self.directory(desktop_grid, args, label, f, is_for_desktop)
				return self.directory(args)
			end
		else
			if launcher_utils.is_desktop_file(args.file_path) and args.show_desktop_launchers then
				--return self.desktop(desktop_grid, args, label, f, is_for_desktop)
				return self.desktop(args)
			else
				if args.show_files then
					--return self.document(desktop_grid, args, label, f, is_for_desktop)
					return self.document(args)
				end
			end
		end
	end,
})

return generators
