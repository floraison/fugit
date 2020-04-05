
## gem tasks ##

NAME = \
  $(shell ruby -e "s = eval(File.read(Dir['*.gemspec'][0])); puts s.name")
VERSION = \
  $(shell ruby -e "s = eval(File.read(Dir['*.gemspec'][0])); puts s.version")

count_lines:
	find lib -name "*.rb" | xargs cat | ruby -e "p STDIN.readlines.count { |l| l = l.strip; l[0, 1] != '#' && l != '' }"
	find spec -name "*_spec.rb" | xargs cat | ruby -e "p STDIN.readlines.count { |l| l = l.strip; l[0, 1] != '#' && l != '' }"
cl: count_lines

scan:
	scan lib/**/*.rb

gemspec_validate:
	@echo "---"
	ruby -e "s = eval(File.read(Dir['*.gemspec'].first)); p s.validate"
	@echo "---"

name: gemspec_validate
	@echo "$(NAME) $(VERSION)"

cw:
	find lib -name "*.rb" -exec ruby -cw {} \;

build: gemspec_validate
	gem build $(NAME).gemspec
	mkdir -p pkg
	mv $(NAME)-$(VERSION).gem pkg/

push: build
	gem push --otp "$(OTP)" pkg/$(NAME)-$(VERSION).gem

spec:
	bundle exec rspec
test: spec


## specific to project ##

info:
	uname -a
	bundle exec ruby -v
	bundle exec ruby -Ilib -r et-orbi -e "EtOrbi._make_info"

tzones:
	bundle exec ruby -r tzinfo -e "TZInfo::Timezone.all.each { |tz| p tz.name }"
#tzonesd:
#	bundle exec ruby -r tzinfo -r tzinfo-data -e "::TZInfo::Timezone.all.each { |tz| p tz.name }"


.PHONY: count_lines scan gemspec_validate name cw build push spec info tzones

