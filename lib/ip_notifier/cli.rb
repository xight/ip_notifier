require "ip_notifier"
require "thor"

module IpNotifier
	class CLI < Thor
		desc "check", "check"
		include IpNotifier
		def check
			IpNotifier.check
		end
	end
end
