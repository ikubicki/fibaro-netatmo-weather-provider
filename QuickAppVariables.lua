class 'QuickAppVariables'

function QuickAppVariables:format(dict)
    local results = {}
    for name, value in pairs(dict) do
        results[#results+1] = {
            name = name,
            value = value,
        }
    end
    return results
end