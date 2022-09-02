-- Color to RGB value table for Lua coding
-- From https://gist.github.com/jjjesus/4535622
-- Color values copied from "http://www.w3.org/TR/SVG/types.html#ColorKeywords"
--
-- If you need the RGB values for a function list, you can use "colorsRGB.RGB()", like
-- colorsRGB.RGB("chocolate"), which returns the multi value list "210 105 30"
-- This can be used for function parameter input, like for example b:setFillColor(r,g,b):
-- body:setFillColor(colorsRGB.RGB("chocolate"))
--
-- If you need the RGB values as a table, like "{210, 105, 30}" for the "chocolate" color,
-- use a lookup in the color name table "colorsRGB",
-- like "colorsRGB.chocolate" or colorsRGB["chocolate"], which return "{210, 105, 30}"
--
-- If you need the individual R,G,B values, you can use either explicit table lookup:
-- colorsRGB.chocolate[1], colorsRGB.chocolate[2] and colorsRGB.chocolate[3],
-- or convenience functions colorsRGB.R("chocolate"), colorsRGB.G("chocolate") and
-- colorsRGB.B("chocolate"), for the R, G, B-values, respectively.
--
-- Enjoy, Frank (Sep 20, 2010)


--Colors Codes:
--
--Mint Green: 3, 255, 171
--
--00FA9A
--Shiny Blue: 5, 5, 255
--
--0505ff
--Joker Green 2,153, 57
--
--029939
--Pindel Pink: 247, 136, 206
--
--f788ce
--Bleek Banana: 236, 255, 140
--
--ecff8c
--WaterMelon: 187, 235,42
--
--bbeb2a
--Magnetic Blue: 73, 76, 153
--
--494c99
--Aqua Blue: 66, 208, 255
--
--42d0ff
--Toxic Yellow: 221, 255, 3
--
--ddff03
--Epsilon Blue 135,197,245
--
--87c5f5
--Digital Green 0,255,0
--
--00ff00
--Bright Purple 96,62,148
--
--603e94
--Neon Pink 255,105,180
--
--ff69b4
--Bright Gold 227,190,70
--
--e3be46
--Turkey Stuffer Green
--
--16a112
--22,161,18
--
--Neon Blue
--
--05c1ff
--5,193,255
--
--Neon Purple
--
--1b1da3
--Kifflom
--
--87c5f5
--135,197,245
--
--3rd Street Saints Purple
--
--603e94
--96,62,148
--
--Light Gold Chrome
--
--e3be46
--227,190,70
--
--Dark Gold Chrome
--
--fbb829
--251,184,41
--
--Black Crew Color
--
--030303
--3,3,3
--
--White Crew Color
--
--ffffff
--255,255,255
--
--Hot Pink
--
--ff69b4
--255,105,180
--
--Kifflom 135,197,245
--
--87c5f5
--Bright Gold 227,190,70
--
--e3be46
--Detox Purple: 157,153,188
--
--9D99BC
--Glossy Green: 0,70,0
--
--004600
--Flirty Purple: 58,5,94
--
--610dab
--Bold Purple: 107,33,76
--
--6B214C
--Flirty Purple: 58,5,94
--
--610dab
--Pindel Pink 247, 136, 206
--
--f788ce
--Neon Green:
--
--16a112
--22,161,18
--
--Great Color: 14,0,14
--
--0E000E0
--Neon Green 2:
--
--7FFF96
--127, 255, 150
--
--Great Color 2:
--
--B976ED
--185, 118, 237
--
--Sky Blue:
--
--7FC8FF
--127, 200, 255
--
--Blue Cheat:
--
--FD7G97
--155, 200, 255
--
--Neon Pink 2:
--
--FF49EA
--255, 73, 234
--
--Neon Sky Blue:
--
--7BFFFF
--123, 255, 255
--
--Invisible Color:
--
--0E000E0
--14, 0, 14

colorsRGB = {
    black = {0, 0, 0},
    blue = {0, 0, 255},
    silver = {192, 192, 192},
    gray = {128, 128, 128},
    green = {0, 128, 0},
    purple = {128, 0, 128},
    red = {255, 0, 0},
    white = {255, 255, 255},
    orange = {156, 63, 30},
    yellow = {255, 255, 0},
    lime = {0, 255, 0},
    maroon = {128, 0, 0},
    olive = {128, 128, 0},
    aqua = {0, 255, 255},
    cyan = {0, 255, 255},
    teal = {0, 128, 128},
    navy = {0, 0, 128},
    magenta = {255, 0, 255},
    fuchsia = {255, 0, 255},
    skyblue = {135,206,235},
    hotpink = {255,20,147},
    lightpink = {255,182,193},
    pink = {255,192,203},
    wheat = {245,222,179},
    brown = {139,69,19},
    tan = {210,180,140},
    indigo = {75,0,130},
    royalblue = {65,105,225},

    kifflom = { 102, 144,181 }, -- 6690B5
    invisible = { 14, 0, 14 },
    brightgold = { 227, 190, 70 },
    lavared = { 107, 11, 0, 4 },
    gold = {251, 184, 41, 4},
    karbonnic = {14, 0, 14},
    -- chrome = {0, 0, 0, 5},
}

colorsRGB.RANDOM_COLOR = function ()
    local keyset = {}
    local num_colors = 0
    for k in pairs(colorsRGB) do
        if (type(colorsRGB[k]) == "table") then
            num_colors = num_colors + 1
            table.insert(keyset, k)
        end
    end
    local rand = math.random(1, num_colors)
    return colorsRGB[keyset[rand]]
end

colorsRGB.R = function (name)
    return colorsRGB[name][1]
end

colorsRGB.G = function (name)
    return colorsRGB[name][2]
end

colorsRGB.B = function (name)
    return colorsRGB[name][3]
end

colorsRGB.RGB = function (name)
    return colorsRGB[name][1],colorsRGB[name][2],colorsRGB[name][3]
end

local function dec_to_hex(input)
    return ('%X'):format(input)
end

colorsRGB.HEX = function (name)
    return dec_to_hex(colorsRGB[name][1]) .. dec_to_hex(colorsRGB[name][2]) .. dec_to_hex(colorsRGB[name][3])
end

colorsRGB.DEC = function (hexcode)
    return {
        tonumber(string.sub(hexcode, 1, 2),16),
        tonumber(string.sub(hexcode, 3, 4),16),
        tonumber(string.sub(hexcode, 5, 6),16)
    }
end

colorsRGB.COMPLIMENT = function (color)
    return {(255 - color[1]), (255 - color[2]), (255 - color[3])}
end

return colorsRGB