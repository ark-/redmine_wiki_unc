require 'redmine'

class UncHelper
  def initialize
    @head = /^\\\\/
  end

  def is_unc?(str)
    (str =~ @head) != nil
  end

  def unc_to_file_proto(str)
    Rails.logger.info "str == #{str}, is_unc? == #{is_unc?(str)}, head=#{@head.to_s}"
    return "" if !is_unc?(str)
    str.gsub(@head, "file://///").gsub(/\\/, "/")
  end

  def trim(str)
    return str.strip unless str == nil
    return nil
  end

  def parse_args(args)
    unc = trim(args[0])
    label = trim(args[1]) || unc

    return unc, label
  end

  def get_tag(args)
    return "(No parameters are specified. A UNC path is needed at least.)" if args.empty?
    unc, label = parse_args(args)

    return <<TEMPLATE
<a href=\"#{unc_to_file_proto(unc)}\">#{label}</a>
TEMPLATE
  end

end

Redmine::Plugin.register :redmine_wiki_unc do
  name 'Redmine Wiki Unc plugin'
  author 'Takashi Oguma'
  description 'This is a plugin for macro of Redmine Wiki'
  version '0.0.3'

  Redmine::WikiFormatting::Macros.register do
    desc <<DESC
Makes a link to UNC path.
How to use:
1) without a label: {{unc(\\\\server\\path\\to\\file)}}
2) with a label:    {{unc(\\\\server\\path\\to\\file, My Secret Document)}}
DESC

    macro :unc do |obj, args|
      h = UncHelper.new
      h.get_tag(args).html_safe
    end
  end
end

class UriSchemeHelper

  def trim(str)
    return str.strip unless str == nil
    return nil
  end

  def parse_args(args)
    custom_uri = trim(args[0])
    label = trim(args[1]) || custom_uri

    return custom_uri, label
  end

  def get_tag(args)
    return "(No parameters are specified. A valid URI is expected.)" if args.empty?
    custom_uri, label = parse_args(args)

    return <<TEMPLATE
<a href=\"#{custom_uri}\">#{label}</a>
TEMPLATE
  end

end

Redmine::Plugin.register :redmine_wiki_customlink do
  name 'Redmine Wiki Custom URI Scheme Links plugin'
  author 'ark-'
  description 'This is a plugin to allow custom URI scheme links in redmine, also known as a browser protocol'
  version '0.0.1'

  Redmine::WikiFormatting::Macros.register do
    desc <<DESC
Makes a link to custom protocol path.
How to use:
1) without a label: {{custom_link(steam://browsemedia)}}
2) with a label:    {{custom_link(steam://friends/, Open Steam friends list)}}
DESC

    macro :custom_link do |obj, args|
      h = UriSchemeHelper.new
      h.get_tag(args).html_safe
    end
  end
end