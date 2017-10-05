require "yaml"
require "logger"
require "typhoeus"

class IPNotifier
	@@config = YAML.load_file("config.yaml")
	@@URL = "https://dyn.value-domain.com/cgi-bin/dyn.fcg?ip"
	@@logger = Logger.new('log/log')

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

	def get_current_ip
		return Typhoeus.get(@@URL).options[:response_body].strip
	end

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

	def check()
		current_ip = get_current_ip
		previous_ip = get_previous_ip

		log("info", "Current : #{current_ip}")
		log("info", "Previous: #{previous_ip}")

		if current_ip != previous_ip
			update_ip(current_ip)

			notify(current_ip)

		else
			log("info", "Not updated")
		end
	end
end

IPNotifier.new.check
