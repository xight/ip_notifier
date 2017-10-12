require "ip_notifier"
require "thor"

module IpNotifier
	class CLI < Thor
		require "yaml"
		require "logger"
		require "typhoeus"

		@@config = YAML.load_file("config.yaml")
		@@URL = "https://dyn.value-domain.com/cgi-bin/dyn.fcg?ip"
		@@logger = Logger.new('log/log')

		desc "check", "check"
		def check
			current_ip = get_current_ip
			previous_ip = get_previous_ip

			log("info", "Current : #{current_ip}")
			log("info", "Previous: #{previous_ip}")

			if current_ip != previous_ip and !current_ip.empty?
				update_ip(current_ip)
				notify(current_ip)
			else
				log("info", "Not updated")
			end
		end

		desc "", ""
		def get_current_ip
			request = Typhoeus::Request.new(@@URL, followlocation: true)

			request.on_complete do |response|
				if response.success?
					return response.options[:response_body].strip
				elsif response.timed_out?
					log("error", "Typhoeus: got a time out")
				elsif response.code == 0
					# Could not get an http response, something's wrong.
					log("error", response.return_message)
				else
					# Received a non-successful http response.
					log("error", "HTTP request failed: " + response.code.to_s)
				end
			end
			request.run
		end

		desc "", ""
		def get_previous_ip
			begin
				file = File.open("log/latest","r+")
				return file.read.strip
			rescue SystemCallError => e
				log("error", %Q(class=[#{e.class}] message=[#{e.message}]))
			rescue IOError => e
				log("error", %Q(class=[#{e.class}] message=[#{e.message}]))
			end
			return nil
		end

		desc "", ""
		def update_ip(ip)
			begin
				file = File.open("log/latest","w")
				file.puts(ip)
				log("info", "log updated")
				return
			rescue SystemCallError => e
				log("error", %Q(class=[#{e.class}] message=[#{e.message}]))
			rescue IOError => e
				log("error", %Q(class=[#{e.class}] message=[#{e.message}]))
			end
		end

		desc "", ""
		def notify(body)
			require "mail"

			Mail.defaults do
				delivery_method :smtp, {
					address:   @@config["smtp"]["host"],
					port:      @@config["smtp"]["port"],
					domain:    @@config["smtp"]["domain"],
					user_name: @@config["smtp"]["user"],
					password:  @@config["smtp"]["password"],
					#password:  ($stderr.print 'password> '; gets.chomp) }
					authentication: 'plain',
					enable_starttls_auto: true
				}
			end

			mail = Mail.new do
				from     @@config["mail"]["from"]
				to       @@config["mail"]["to"]
				subject  @@config["mail"]["subject"]
				body     body
			end

			mail.charset = "UTF-8"
			mail.content_transfer_encoding = "8bit"
			mail.deliver
			log("info", "notified #{@@config["mail"]["to"]}")
		end

		desc "", ""
		def log(level,message)
			puts message

			if level == "fatal"
				@@logger.fatal(message)
			elsif level == "warn"
				@@logger.warn(message)
			elsif level == "error"
				@@logger.error(message)
			elsif level == "info"
				@@logger.info(message)
			elsif level == "debug"
				@@logger.debug(message)
			else
				@@logger.unknown(message)
			end
		end
	end
end
