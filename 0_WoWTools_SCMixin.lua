WoWTools_SCMixin= {}

function WoWTools_SCMixin:IsCN(text)
    return
        text
        and text:find('[\228-\233]')
        and not text:find('DNT')
        and not text:find('UNUSED')
        and not text:find('TEST')
end


function WoWTools_SCMixin:MK(number, notColor)
    number= number and tonumber(number)
    if not number then
        return
    end

    local b=3
    local t=''
    local hex
    if number>=1e8 then
        number= (number/1e8)-- 1 0000 0000
        hex='|cffff4800%s|r'
        t='m'
        b=8
    elseif number>= 1e4 then
        number= (number/1e4)
        hex= '|cffff00ff%s|r'
        t='w'
        b=4
    elseif number>=1e3 then
        number= (number/1e3)
        hex= '|cff00ff00%s|r'
        t='k'
    else
        return number..''
    end

    local num, point= math.modf(number)
    if not notColor then
        t= format(hex, t)
    end

    if point==0 then
        return num..t
    else--0.5/10^bit
        return format('%0.'..b..'f', number):gsub('%.', t)
    end
end

function WoWTools_SCMixin:InitTable(name, tab)
    local buildVersion, buildNumber = GetBuildInfo()
    local text= format('%s 数据版本 %s - %s 总数 %s, 由 WoWTools Chinese Scanner 插件收集',
            name,
            buildVersion,
            buildNumber,
            tab and self:MK(CountTable(tab), true) or '0'
    )
    if tab then

        tab[0]= text
    else
        return { [0]= text}
    end
end