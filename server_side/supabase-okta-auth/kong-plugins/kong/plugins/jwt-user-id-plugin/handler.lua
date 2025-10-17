local cjson = require "cjson"

local JwtUserIdPluginHandler = {
    PRIORITY = 1000,
    VERSION = "1.0.0",
}

-- Простая функция для декодирования base64
local function base64_decode(str)
    -- Добавляем padding если нужно
    local padding = 4 - (str:len() % 4)
    if padding ~= 4 then
        str = str .. string.rep("=", padding)
    end
    
    -- Используем ngx.decode_base64
    local decoded = ngx.decode_base64(str)
    return decoded
end

-- Простая функция для декодирования JWT payload
local function decode_jwt_payload(token)
    local parts = {}
    for part in token:gmatch("[^%.]+") do
        table.insert(parts, part)
    end
    
    if #parts ~= 3 then
        return nil, "Invalid JWT format"
    end
    
    local payload_part = parts[2]
    -- Добавляем padding если нужно
    local padding = 4 - (payload_part:len() % 4)
    if padding ~= 4 then
        payload_part = payload_part .. string.rep("=", padding)
    end
    
    local decoded = base64_decode(payload_part)
    if not decoded then
        return nil, "Failed to decode payload"
    end
    
    local payload = cjson.decode(decoded)
    return payload, nil
end

function JwtUserIdPluginHandler:access(conf)
    local jwt_token = nil
    
    -- Получаем JWT токен из заголовка Authorization
    local auth_header = kong.request.get_header("Authorization")
    if auth_header then
        local token = auth_header:match("Bearer%s+(.+)")
        if token then
            jwt_token = token
        end
    end
    
    -- Если токен не найден в заголовке, попробуем получить из query параметра
    if not jwt_token then
        jwt_token = kong.request.get_query_arg("jwt")
    end
    
    if not jwt_token then
        kong.log.err("JWT token not found in request")
        return kong.response.exit(401, { message = "JWT token required" })
    end
    
    -- Декодируем JWT payload (без проверки подписи для простоты)
    local payload, err = decode_jwt_payload(jwt_token)
    
    if not payload then
        kong.log.err("Failed to decode JWT payload: ", err)
        return kong.response.exit(401, { message = "Invalid JWT token" })
    end
    
    -- Извлекаем user ID из payload
    local user_id = payload[conf.user_id_field]
    
    if not user_id then
        kong.log.err("User ID field '", conf.user_id_field, "' not found in JWT payload")
        return kong.response.exit(401, { message = "User ID not found in token" })
    end
    
    -- Добавляем заголовок с user ID
    kong.service.request.set_header(conf.header_name, user_id)
    
    kong.log.info("JWT parsed successfully, user ID: ", user_id, ", header: ", conf.header_name)
end

return JwtUserIdPluginHandler
