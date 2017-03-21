-- Copyright 2008 Steven Barth <steven@midlink.org>
-- Copyright 2008 Jo-Philipp Wich <jow@openwrt.org>
-- Licensed to the public under the Apache License 2.0.

m = Map("samba", translate("Network Shares"))

s = m:section(TypedSection, "samba", "Samba")
s.anonymous = true



s:tab("general",  translate("General Settings"))
s:tab("template", translate("Edit Template"))

s:taboption("general", Value, "name", translate("Hostname"))
s:taboption("general", Value, "description", translate("Description"))
s:taboption("general", Value, "workgroup", translate("Workgroup"))
s:taboption("general", Value, "homes", translate("Share home-directories"),
        translate("Allow system users to reach their home directories via " ..
                "network shares"))
local state_msg = ""
local samba_on = (luci.sys.call("pidof smbd > /dev/null") == 0)
if samba_on then	
	state_msg = "禁用"
else
	state_msg = "启用"
end

_button_enable = s:taboption ("general",Button, "_button_enable", translate("是否开启"),translate("如果不需要文件共享的功能，可以关闭以节省内存")) 
_button_enable.inputtitle = translate (state_msg)
_button_enable.inputstyle = "apply" 
function _button_enable.write (self, section, value)
	if samba_on then	
		luci.sys.call ( "/etc/init.d/samba stop > /dev/null")
		luci.sys.call ( "/etc/init.d/samba disable > /dev/null")
	else
		luci.sys.call ( "/etc/init.d/samba restart > /dev/null")
		luci.sys.call ( "/etc/init.d/samba enable > /dev/null")
	end
end 

tmpl = s:taboption("template", Value, "_tmpl",
	translate("Edit the template that is used for generating the samba configuration."), 
	translate("This is the content of the file '/etc/samba/smb.conf.template' from which your samba configuration will be generated. " ..
		"Values enclosed by pipe symbols ('|') should not be changed. They get their values from the 'General Settings' tab."))

tmpl.template = "cbi/tvalue"
tmpl.rows = 20

function tmpl.cfgvalue(self, section)
	return nixio.fs.readfile("/etc/samba/smb.conf.template")
end

function tmpl.write(self, section, value)
	value = value:gsub("\r\n?", "\n")
	nixio.fs.writefile("//etc/samba/smb.conf.template", value)
end


s = m:section(TypedSection, "sambashare", translate("Shared Directories"))
s.anonymous = true
s.addremove = true
s.template = "cbi/tblsection"

s:option(Value, "name", translate("Name"))
pth = s:option(Value, "path", translate("Path"))
if nixio.fs.access("/etc/config/fstab") then
        pth.titleref = luci.dispatcher.build_url("admin", "system", "fstab")
end

s:option(Value, "users", translate("Allowed users")).rmempty = true

ro = s:option(Flag, "read_only", translate("Read-only"))
ro.rmempty = false
ro.enabled = "yes"
ro.disabled = "no"

go = s:option(Flag, "guest_ok", translate("Allow guests"))
go.rmempty = false
go.enabled = "yes"
go.disabled = "no"

cm = s:option(Value, "create_mask", translate("Create mask"),
        translate("Mask for new files"))
cm.rmempty = true
cm.size = 4

dm = s:option(Value, "dir_mask", translate("Directory mask"),
        translate("Mask for new directories"))
dm.rmempty = true
dm.size = 4

return m
