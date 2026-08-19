local total_sum = 0.0

function format_with_thousands(value, decimals)
    if value == nil then return "" end
    if decimals == nil then decimals = 2 end
    
    local formatted = string.format("%." .. decimals .. "f", value)
    local int_part, dec_part = string.match(formatted, "^(%-?%d+)(%.%d+)$")
    
    if not int_part then
        int_part = formatted
        dec_part = ""
    end
    
    local num_parts = {}
    while string.len(int_part) > 3 do
        table.insert(num_parts, 1, string.sub(int_part, -3))
        int_part = string.sub(int_part, 1, -4)
    end
    table.insert(num_parts, 1, int_part)
    
    return table.concat(num_parts, ",") .. dec_part
end

function handle_record(record)
    local is_subtotal = record:get("IS_SUBTOTAL")
    local group = record:get("GRP")
    local balance = tonumber(record:get("BALANCE"))
    local rate = tonumber(record:get("CURRVALUE"))
    local base_single = tonumber(record:get("BASE_SINGLE"))
    local base_sum = tonumber(record:get("BASE_SUM"))
    local precision = tonumber(record:get("SCALE"))

    -- Format balance
    local result
    if precision == 1 then
        result = format_with_thousands(balance, 0)
    elseif precision == 10 then
        result = format_with_thousands(balance, 1)
    else
        result = format_with_thousands(balance, 2)
    end
    record:set("BALANCE", result)

    -- Exchange rate
    record:set("RATE", string.format("%.4f", rate))

    --------------------------------------------------------------------
    -- Display logic: Rate / Base per Account / Conversion
    --------------------------------------------------------------------

    if is_subtotal == "1" then
        -- SUBTOTAL → only conversion + included in total
        record:set("BASE_SINGLE", "")
        record:set("BASE", format_with_thousands(base_sum, 2))
        total_sum = total_sum + base_sum

    else
        -- ALL non-subtotals: show Base per Account
        record:set("BASE_SINGLE", format_with_thousands(base_single, 2))

        if group ~= "" then
            -- GROUP ACCOUNT → Base per Account only, no conversion
            record:set("BASE", "")
        else
            -- SINGLE ACCOUNT (CHF or foreign currency)
            record:set("BASE", format_with_thousands(base_single, 2))
            total_sum = total_sum + base_single
        end
    end
end

function complete(result)
    result:set("SUMMA", format_with_thousands(total_sum, 2))
end
