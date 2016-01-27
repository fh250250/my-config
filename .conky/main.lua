require('cairo')

function rgb_to_r_g_b(colour,alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

---------------------------------> draw lines
function draw_line(cr, line)

  local color, alpha, width, path = line['color'], line['alpha'], line['width'], line['path']

  cairo_set_source_rgba(cr,rgb_to_r_g_b(color, alpha))
  cairo_set_line_width(cr, width)

  for i in pairs(path) do
    if i == 1 then
      cairo_move_to(cr, path[i][1], path[i][2])
    else
      cairo_line_to(cr, path[i][1], path[i][2])
    end
  end

  cairo_stroke(cr)
end

---------------------------------> draw rings
function draw_ring(cr,t,pt)
    local w,h=conky_window.width,conky_window.height

    local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
    local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

    local angle_0=sa*(2*math.pi/360)-math.pi/2
    local angle_f=ea*(2*math.pi/360)-math.pi/2
    local t_arc=t*(angle_f-angle_0)

-- Draw background ring

    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
    cairo_set_line_width(cr,ring_w)
    cairo_stroke(cr)
    
-- Draw indicator ring

    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
    cairo_stroke(cr)
end

function conky_draw()
    local function setup_rings(cr,pt)
    local str=''
    local value=0

    str=string.format('${%s %s}',pt['name'],pt['arg'])
    str=conky_parse(str)

    value=tonumber(str)
    if not value then
        value=0
    end
    pct=value/pt['max']

    draw_ring(cr,pct,pt)
end


-- Check that Conky has been running for at least 5s

if conky_window==nil then return end
    local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)

    local cr=cairo_create(cs)

    local updates=conky_parse('${updates}')
    update_num=tonumber(updates)

    if update_num>5 then
        for i in pairs(rings_table) do
            setup_rings(cr,rings_table[i])
        end

        for i in pairs(lines_table) do
            draw_line(cr, lines_table[i])
        end
    end
end
