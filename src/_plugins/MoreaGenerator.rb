# Processes pages in the morea directory.
# Adapted from: https://github.com/bbakersmith/jekyll-pages-directory

module Jekyll

  class MoreaGenerator < Generator

    attr_accessor :summary

    def configSite(site)
      site.config['morea_module_pages'] = []
      site.config['morea_prerequisite_pages'] = []
      site.config['morea_outcome_pages'] = []
      site.config['morea_reading_pages'] = []
      site.config['morea_experience_pages'] = []
      site.config['morea_assessment_pages'] = []
      site.config['morea_home_page'] = nil
      site.config['morea_footer_page'] = nil
      site.config['morea_page_table'] = {}
      site.config['morea_fatal_errors'] = false
      if (site.config['morea_navbar_items'] == nil)
        site.config['morea_navbar_items'] = ["Modules", "Outcomes", "Readings", "Experiences", "Assessments"]
      end
      if (site.config['morea_course'] == nil)
        site.config['morea_course'] = ''
      else
        site.config['morea_course'] = site.config['morea_course'].to_s
      end
      if (site.config['morea_domain'] == nil)
        site.config['morea_domain'] = ''
      else
        site.config['morea_domain'] = site.config['morea_domain'].to_s
        if site.config['morea_domain'].end_with?("/")
          site.config['morea_domain'].chop!
        end
      end
    end

    def generate(site)
      puts "\nStarting Morea page processing..."
      @fatal_errors = false
      configSite(site)
      #print_obj_info(site)
      puts "Site destination:" + site.config['destination']
      @summary = MoreaGeneratorSummary.new(site)
      morea_dir = site.config['morea_dir'] || 'morea'
      morea_file_paths = Dir["#{site.source}/#{morea_dir}/**/*"]
      morea_file_paths.each do |f|
        if File.file?(f) and !hasIgnoreDirectory?(f)
          file_name = f.match(/[^\/]*$/)[0]
          relative_file_path = f.gsub(/^#{morea_dir}\//, '')
          relative_file_path = relative_file_path[(site.source.size + morea_dir.size + 1)..relative_file_path.size]
          subdir = extract_directory(relative_file_path)

          @summary.total_files += 1
          puts "  Processing file:  #{subdir}#{file_name}"
          if File.extname(file_name) == '.md'
            @summary.morea_files += 1
            processMoreaFile(site, subdir, file_name, morea_dir)
          else
            @summary.non_morea_files += 1
            processNonMoreaFile(site, subdir, file_name, morea_dir)
          end
        end
      end

      # Now that all Morea files are read in, do analyses that require access to all files.
      check_for_undeclared_morea_id_references(site)
      set_referencing_modules(site)
      set_referencing_assessment(site)
      print_morea_problems(site)
      check_for_undefined_home_page(site)
      check_for_undefined_footer_page(site)
      fix_morea_urls(site)
      set_due_date(site)
      sort_pages(site)
      unless (site.config['morea_course'] == '')
        ModuleInfoFile.new(site).write_module_info_file
      end
      ScheduleInfoFile.new(site).write_schedule_info_file
      puts @summary
      if site.config['morea_fatal_errors']
        puts "Errors found. Exiting."
        exit
      end
    end

    def hasIgnoreDirectory?(path)
      #if Pathname(path).each_filename.to_a.include?("_ignore")
      #  puts "  Ignoring " + path
      #end
      return Pathname(path).each_filename.to_a.include?("_ignore")
    end

    def sort_pages(site)
      site.config['morea_module_pages'] = site.config['morea_module_pages'].sort_by {|page| page.data['morea_sort_order']}
      site.config['morea_outcome_pages'] = site.config['morea_outcome_pages'].sort_by {|page| page.data['morea_sort_order']}
      site.config['morea_reading_pages'] = site.config['morea_reading_pages'].sort_by {|page| page.data['morea_sort_order']}
      site.config['morea_experience_pages'] = site.config['morea_experience_pages'].sort_by {|page| page.data['morea_sort_order']}
      site.config['morea_assessment_pages'] = site.config['morea_assessment_pages'].sort_by {|page| page.data['morea_sort_order']}
    end

    # Prepend site.baseurl to reading pages and prerequisites containing a morea_url that does not start with http.
    def fix_morea_urls(site)
      site.config['morea_reading_pages'].each do |reading_page|
        reading_url = reading_page.data['morea_url']
        if reading_url.match(/^\/morea/)
          reading_page.data['morea_url'] = site.baseurl + reading_url
        end
      end
      site.config['morea_experience_pages'].each do |experience_page|
        experience_url = experience_page.data['morea_url']
        if experience_url.match(/^\/morea/)
          experience_page.data['morea_url'] = site.baseurl + experience_url
        end
      end
      site.config['morea_assessment_pages'].each do |assessment_page|
        assessment_page.data['morea_url'] = site.baseurl + "/assessments#" + assessment_page.data['morea_id']
      end
      site.config['morea_prerequisite_pages'].each do |prereq_page|
        prereq_url = prereq_page.data['morea_url']
        if prereq_url.match(/^\/modules/)
          prereq_page.data['morea_url'] = site.baseurl + prereq_url
        end
        icon_url = prereq_page.data['morea_icon_url']
        if icon_url.match(/^\/morea/)
          prereq_page.data['morea_icon_url'] = site.baseurl + icon_url
        end
      end
    end


    # Tell each outcome, assessment, experience, and reading all the modules that referred to it.
    def set_referencing_modules(site)
      site.config['morea_module_pages'].each do |module_page|
        module_page.data['morea_outcomes'].each do |outcome_id|
          outcome = site.config['morea_page_table'][outcome_id]
          if outcome
            unless module_page.data['morea_coming_soon']
              outcome.data['referencing_modules'] << module_page
            end
          end
        end
      end

      site.config['morea_module_pages'].each do |module_page|
        module_page.data['morea_assessments'].each do |assessment_id|
          assessment = site.config['morea_page_table'][assessment_id]
          if assessment
            unless module_page.data['morea_coming_soon']
              assessment.data['referencing_modules'] << module_page
            end
          end
        end
      end

      site.config['morea_module_pages'].each do |module_page|
        module_page.data['morea_readings'].each do |reading_id|
          reading = site.config['morea_page_table'][reading_id]
          if reading
            unless module_page.data['morea_coming_soon']
              reading.data['referencing_modules'] << module_page
            end
          end
        end
      end

      site.config['morea_module_pages'].each do |module_page|
        module_page.data['morea_experiences'].each do |experience_id|
          experience = site.config['morea_page_table'][experience_id]
          if experience
            unless module_page.data['morea_coming_soon']
              experience.data['referencing_modules'] << module_page
            end
          end
        end
      end
    end



    # Tell each outcome all the assessments that referred to it.
    def set_referencing_assessment(site)
      site.config['morea_assessment_pages'].each do |assessment_page|
        assessment_page.data['morea_outcomes_assessed'].each do |outcome_id|
          outcome = site.config['morea_page_table'][outcome_id]
          if outcome
            unless assessment_page.data['morea_coming_soon']
              outcome.data['morea_referencing_assessments'] << assessment_page
            end
          end
        end
      end
    end


    # For readings, experiences, and assessments with a due date, add a label.
    def set_due_date (site)
      pages = site.config['morea_experience_pages'] + site.config['morea_reading_pages'] + site.config['morea_assessment_pages']
      pages.each do |page|
        if page.data['morea_start_date']
          if page.data['morea_labels'] == nil
            page.data['morea_labels'] = []
          end
          page.data['morea_labels'] << "#{(Time.parse(page.data['morea_start_date'])).strftime("%d %b %I:%M %p")}"
        end
      end
    end


    def print_morea_problems(site)
      site.config['morea_page_table'].each do |morea_id, morea_page|
        morea_page.print_problems_if_any
      end
    end

    def check_for_undefined_home_page(site)
      unless site.config['morea_home_page']
        puts "  Warning:  no home page content. Define a page with 'morea_type: home' to fix."
        @summary.yaml_warnings += 1
      end
    end

    def check_for_undefined_footer_page(site)
      unless site.config['morea_footer_page']
        puts "  Warning:  no footer content. Define a page with 'morea_type: footer' to fix."
        @summary.yaml_warnings += 1
      end
    end


    def check_for_undeclared_morea_id_references(site)
      site.config['morea_page_table'].each do |morea_id, morea_page|

        # Check that morea_outcomes_assessed are all valid morea IDs.
        # If so, add the associated instance to morea_related_outcomes
        if morea_page.data['morea_outcomes_assessed']
          morea_page.data['morea_outcomes_assessed'].each do |morea_id_reference|
            if site.config['morea_page_table'][morea_id_reference]
              morea_page.data['morea_related_outcomes'] << site.config['morea_page_table'][morea_id_reference]
            else
              morea_page.undefined_id << morea_id_reference
              @summary.yaml_errors += 1
            end
          end
        end

        # Check for required tags for module pages.
        if (morea_page.data['morea_type'] == 'module')
          if morea_page.data['morea_outcomes']
            morea_page.data['morea_outcomes'].each do |morea_id_reference|
              unless site.config['morea_page_table'][morea_id_reference]
                morea_page.undefined_id << morea_id_reference
                @summary.yaml_errors += 1
              end
            end
          end
          if morea_page.data['morea_readings']
            morea_page.data['morea_readings'].each do |morea_id_reference|
              unless site.config['morea_page_table'][morea_id_reference]
                morea_page.undefined_id << morea_id_reference
                @summary.yaml_errors += 1
              end
            end
          end
          if morea_page.data['morea_experiences']
            morea_page.data['morea_experiences'].each do |morea_id_reference|
              unless site.config['morea_page_table'][morea_id_reference]
                morea_page.undefined_id << morea_id_reference
                @summary.yaml_errors += 1
              end
            end
          end
          if morea_page.data['morea_assessments']
            morea_page.data['morea_assessments'].each do |morea_id_reference|
              unless site.config['morea_page_table'][morea_id_reference]
                morea_page.undefined_id << morea_id_reference
                @summary.yaml_errors += 1
              end
            end
          end
        end
      end
    end

    # Copy all non-markdown files to destination directory unchanged.
    # Jekyll will create a morea directory in the destination that holds these files.
    # If the file suffix is '.markdown', it becomes a Page, otherwise a StaticPage.
    def processNonMoreaFile(site, relative_dir, file_name, morea_dir)
      source_dir = morea_dir + "/" + relative_dir
      if File.extname(file_name) == '.markdown'
        site.pages << Jekyll::Page.new(site, site.source, source_dir, file_name)
      else
        site.static_files << Jekyll::StaticFile.new(site, site.source, source_dir, file_name)
      end
    end

    def processMoreaFile(site, subdir, file_name, morea_dir)
      new_page = MoreaPage.new(site, subdir, file_name, morea_dir)
      validate(new_page, site)
      # Ruby Newbie Alert. There is definitely a one liner to do the following:
      # Note that even pages with errors are going to try to be published.
      if new_page.published?
        @summary.published_files += 1
        site.pages << new_page
        site.config['morea_page_table'][new_page.data['morea_id']] = new_page
        if new_page.data['morea_type'] == 'module'
          site.config['morea_module_pages'] << new_page
          module_page = ModulePage.new(site, site.source, new_page.data['morea_id'], new_page)
          site.pages << module_page
        elsif new_page.data['morea_type'] == 'outcome'
          site.config['morea_outcome_pages'] << new_page
        elsif new_page.data['morea_type'] == "reading"
          site.config['morea_reading_pages'] << new_page
        elsif new_page.data['morea_type'] == "experience"
          site.config['morea_experience_pages'] << new_page
        elsif new_page.data['morea_type'] == "assessment"
          site.config['morea_assessment_pages'] << new_page
        elsif new_page.data['morea_type'] == "prerequisite"
          site.config['morea_prerequisite_pages'] << new_page
        elsif new_page.data['morea_type'] == "home"
          site.config['morea_home_page'] = new_page
        elsif new_page.data['morea_type'] == "footer"
          site.config['morea_footer_page'] = new_page
        elsif new_page.data['morea_type'] == "overview_modules"
          site.config['morea_overview_modules'] = new_page
        elsif new_page.data['morea_type'] == "overview_outcomes"
          site.config['morea_overview_outcomes'] = new_page
        elsif new_page.data['morea_type'] == "overview_readings"
          site.config['morea_overview_readings'] = new_page
        elsif new_page.data['morea_type'] == "overview_experiences"
          site.config['morea_overview_experiences'] = new_page
        elsif new_page.data['morea_type'] == "overview_assessments"
          site.config['morea_overview_assessments'] = new_page
        end
      else
        @summary.unpublished_files += 1
      end
    end

    def extract_directory(filepath)
      dir_match = filepath.match(/(.*\/)[^\/]*$/)
      if dir_match
        return dir_match[1]
      else
        return ''
      end
    end

    # Print out variables associated with obj. For debugging.
    def print_obj_info(obj)
      obj.instance_variables.map{|var| puts [var, obj.instance_variable_get(var)].join(":")}
    end

    def validate(morea_page, site)
      # Check for required tags: morea_id, morea_type, and title.
      if !morea_page.data['morea_id']
        morea_page.missing_required << "morea_id"
        @summary.yaml_errors += 1
      end
      if !morea_page.data['morea_type']
        morea_page.missing_required << "morea_type"
        @summary.yaml_errors += 1
      end
      if !morea_page.data['title']
        morea_page.missing_required << "title"
        @summary.yaml_errors += 1
      end

      # Check for required tags for experience and reading pages.
      if (morea_page.data['morea_type'] == 'experience') || (morea_page.data['morea_type'] == 'reading')
          if !morea_page.data['morea_summary']
          morea_page.missing_required << "morea_summary"
          @summary.yaml_errors += 1
        end
        if !morea_page.data['morea_url']
          # When not supplied we automatically generate the relative URL to the page.
          # Note we include the baseurl so that for readings and experiences, this link is absolute.
          # We may or may not need a / separator depending upon the underlying version of Jekyll.
          slasher = '/'
          if (morea_page.dir.end_with? '/') || (morea_page.basename.start_with? '/')
            slasher = ''
          end
          morea_page.data['morea_url'] ="#{site.baseurl}#{morea_page.dir}#{slasher}#{morea_page.basename}.html"
        end
      end

      # Check for required/optional tags for module pages.
      if (morea_page.data['morea_type'] == 'module')
        if !morea_page.data['morea_outcomes']
          morea_page.missing_optional << "morea_outcomes"
          morea_page.data['morea_outcomes'] = []
          @summary.yaml_warnings += 1
        end
        if !morea_page.data['morea_readings']
          morea_page.missing_optional << "morea_readings"
          morea_page.data['morea_readings'] = []
          @summary.yaml_warnings += 1
        end
        if !morea_page.data['morea_experiences']
          morea_page.missing_optional << "morea_experiences"
          morea_page.data['morea_experiences'] = []
          @summary.yaml_warnings += 1
        end
        if !morea_page.data['morea_assessments']
          morea_page.missing_optional << "morea_assessments"
          morea_page.data['morea_assessments'] = []
          @summary.yaml_warnings += 1
        end
        if !morea_page.data['morea_icon_url']
          morea_page.missing_optional << "morea_icon_url (set to /modules/default-icon.png)"
          morea_page.data['morea_icon_url'] = "/modules/default-icon.png"
          @summary.yaml_warnings += 1
        end
      end

      # Check for optional tags for non-home, footer pages
      if (morea_page.data['morea_type'] != 'home') && (morea_page.data['morea_type'] != 'footer')
        if !morea_page.data.has_key?('published')
          morea_page.missing_optional << "published (set to true)"
          morea_page.data['published'] = true
          @summary.yaml_warnings += 1
        end
        if !morea_page.data['morea_sort_order']
          morea_page.missing_optional << "morea_sort_order (set to 0)"
          morea_page.data['morea_sort_order'] = 0
          @summary.yaml_warnings += 1
        end
      end

      # Check for duplicate id
      if morea_page.data['morea_id'] && site.config['morea_page_table'].has_key?(morea_page.data['morea_id'])
        morea_page.duplicate_id = true
        @summary.yaml_errors += 1
      end
    end
  end


  # Every .md file in the morea directory becomes a MoreaPage.
  class MoreaPage < Page
    attr_accessor :missing_required, :missing_optional, :duplicate_id, :undefined_id

    def initialize(site, subdir, file_name, morea_dir)
      @site = site
      read_yaml(File.join(site.source, morea_dir, subdir), file_name)
      @base = site.source
      @dir = morea_dir + "/" + subdir
      #@dir = "modules" + "/" + subdir
      @name = file_name
      @missing_required = []
      @missing_optional = []
      @undefined_id = []
      @duplicate_id = false
      self.data['referencing_modules'] = []

      # Provide defaults
      if (self.data['morea_type'] == 'experience') || (self.data['morea_type'] == 'reading')
          unless self.data['layout']
          self.data['layout'] = 'page'
        end
        unless self.data['topdiv']
          self.data['topdiv'] = 'container'
        end
      end

      unless self.data['morea_prerequisites']
        self.data['morea_prerequisites'] = []
      end
      unless self.data['morea_related_outcomes']
        self.data['morea_related_outcomes'] = []
      end
      unless self.data['morea_outcomes_assessed']
        self.data['morea_outcomes_assessed'] = []
      end
      unless self.data['morea_referencing_assessments']
        self.data['morea_referencing_assessments'] = []
      end
      process(file_name)
      self.render(site.layouts, site.site_payload)

    end

    # Whether the file is published or not, as indicated in YAML front-matter
    # Ruby Newbie Alert: copied this from Convertible cause 'include Convertible' didn't work for me.
    def published?
      !(self.data.has_key?('published') && self.data['published'] == false)
    end

    # Print out variables associated with obj. For debugging.
    def print_obj_info(obj)
      obj.instance_variables.map{|var| puts [var, obj.instance_variable_get(var)].join(":")}
    end

    # Prints a string listing warnings or errors if there were any, otherwise does nothing.
    def print_problems_if_any
      if @missing_required.size > 0
        puts "  Error: #{@name} missing required front matter: " + @missing_required*", "
        site.config['morea_fatal_errors'] = true
      end
      if @missing_optional.size > 0
        puts "  Warning: #{@name} missing optional front matter: " + @missing_optional*", "
      end
      if @duplicate_id
        puts "  Error: #{@name} has duplicate id: #{@data['morea_id']}"
        site.config['morea_fatal_errors'] = true
      end
      if @undefined_id.size > 0
        puts "  Error: #{@name} references undefined morea_id: " + @undefined_id*", "
        site.config['morea_fatal_errors'] = true
      end
    end
  end

  # Module pages are dynamically generated, one per MoreaPage with morea_type = module.
  class ModulePage < Page
    def initialize(site, base, dir, morea_page)
      @site = site
      self.read_yaml(File.join(base, '_layouts'), 'module.html')
      @base = base
      @dir = "modules/" + morea_page.data['morea_id']
      @name = 'index.html'

      self.process(@name)

      # Default morea_summary to the markdown page content if not specified already.
      unless morea_page.data['morea_summary']
        morea_page.data['morea_summary'] = morea_page.output
      end

      self.data['morea_page'] = morea_page
      morea_page.data['module_page'] = self
      self.data['title'] = morea_page.data['title']
    end
  end

  # Markdown pages have the .markdown suffix. We add a default layout and topdiv value.
  class MarkdownPage < Page
    def initialize(site, base, dir, file_name)
      @site = site
      self.read_yaml(File.join(base, '_layouts'), 'default.html')
      @base = base
      @dir = dir
      @name = file_name

      self.process(@name)
      self.data['topdiv'] = 'container'
    end
  end

  # Tallies the files processed in order to provide a summary at end of generator stage.
  class MoreaGeneratorSummary
    attr_accessor :total_files, :published_files, :unpublished_files, :morea_files, :non_morea_files, :yaml_warnings, :yaml_errors

    def initialize(site)
      @site = site
      @total_files = 0
      @published_files = 0
      @unpublished_files = 0
      @morea_files = 0
      @non_morea_files = 0
      @yaml_warnings = 0
      @yaml_errors = 0
    end

    def to_s
      "  Summary:\n    #{@total_files} total, #{@published_files} published, #{@unpublished_files} unpublished, #{@morea_files} markdown, #{@non_morea_files} other\n    #{@site.config['morea_module_pages'].size} modules, #{@site.config['morea_outcome_pages'].size} outcomes, #{@site.config['morea_reading_pages'].size} readings, #{@site.config['morea_experience_pages'].size} experiences, #{@site.config['morea_assessment_pages'].size} assessments\n    #{@yaml_errors} errors, #{@yaml_warnings} warnings"
    end
  end

  # Gather schedule data and write it to the schedule directory in a file called schedule-info.js.
  class ScheduleInfoFile
    def initialize(site)
      @site = site
      @schedule_file_dir = @site.config['source']
      @schedule_file_name = 'schedule-info.js'
      @schedule_file_path= @schedule_file_dir + '/schedule/' + @schedule_file_name
    end

    # Write a file declaring a global variable called moreaEventData containing an array of calendar events.
    def write_schedule_info_file
      schedule_file_contents = 'moreaEventData = '
      schedule_file_contents += get_schedule_events(@site)
      #puts "schedule file contents: \n" + schedule_file_contents
      File.open(@schedule_file_path, 'w') { |file| file.write(schedule_file_contents) }
      @site.static_files << Jekyll::StaticFile.new(@site, @site.source, 'schedule/', @schedule_file_name)
    end

    # Returns a JS array of object literals containing event data in FullCalendar syntax.
    def get_schedule_events(site)
      events = "["
      site.config['morea_page_table'].each do |morea_id, morea_page|
        if morea_page.data.has_key?('morea_start_date')
          event = "\n  {title: #{morea_page.data['title'].inspect}, url: #{get_event_url(morea_page, site).inspect}, start: #{morea_page.data['morea_start_date'].inspect}"
          if morea_page.data.has_key?('morea_end_date')
            event += ", end: #{morea_page.data['morea_end_date'].inspect}"
          end
          event += "},"
          events += event
        end
      end
      if (events.end_with?(","))
        events.chop!
      end
      events += "\n]"
      return events
    end

    # Returns the URL (not including domain name) for this page.
    def get_event_url(morea_page, site)
      if (morea_page.data['morea_type'] == 'module')
        url = "#{site.baseurl}/modules/#{morea_page.data['morea_id']}"
      else  # otherwise the baseurl is included. Weird.
        url = "#{morea_page.data['morea_url']}"
      end
      return url
    end
  end


  # Gathers module metadata and writes it to a top-level file (module-info.js)
  class ModuleInfoFile
    def initialize(site)
      @site = site
      @module_file_dir = @site.config['source']
      @module_file_name = 'module-info.js'
      @module_file_path = @module_file_dir + '/' + @module_file_name
    end

    # Writes out the file module-info.js to the top-level directory.
    # This file contains a variable assignment to a literal object containing module and prereq info.
    def write_module_info_file
      module_file_contents = @site.config['morea_course'] + ' = {' + "\n"
      module_file_contents += get_module_json_string(@site)
      module_file_contents += "\n" + '};'
      #puts "module file contents: \n" + module_file_contents
      File.open(@module_file_path, 'w') { |file| file.write(module_file_contents) }
      @site.static_files << Jekyll::StaticFile.new(@site, @site.source, '', @module_file_name)
    end

    # Create the object literal representing and array of module object literals and an array of prereq object literals.
    def get_module_json_string(site)
      json = "modules: ["
      site.config['morea_module_pages'].each do |mod|
        mod_id = mod.data['morea_id']
        json += "\n  { course: #{site.config['morea_course'].inspect}, title: #{mod.data['title'].inspect}, moduleUrl: #{get_module_url_from_id(mod_id, site).inspect}, sort_order: #{mod.data['morea_sort_order']}, description: #{mod.data['morea_summary'].inspect} },"
      end
      #strip trailing comma
      if (json.end_with?(","))
        json.chop!
      end
      json += "\n],"

      json += "\n prerequisites: ["
      #for module_page in module_pages
      site.config['morea_module_pages'].each do |mod|
        mod_id = mod.data['morea_id']
        # for each prereq in module_page.prerequisites_pages
        mod.data['morea_prerequisites'].each do |prereq_id|
          # create record with module_page.url and prerequisite_page.url
          prereq_entry = "\n  { moduleUrl: #{get_module_url_from_id(mod_id, site).inspect}, prerequisiteUrl: #{get_module_url_from_id(prereq_id, site).inspect} },"
          json += prereq_entry
        end
      end
      if (json.end_with?(","))
        json.chop!
      end
      json += "\n]"
      return json
    end

    # Return the fully qualified URL corresponding to a module ID.
    # Note this requires _config.yml to have the morea_domain property defined.
    def get_module_url_from_id(page_id, site)
      url = ""
      site.config['morea_page_table'].each do |morea_id, morea_page|
        if (morea_id == page_id)
          if (morea_page.data['morea_type'] == 'module')
            url = "#{site.config['morea_domain']}#{site.baseurl}/modules/#{morea_page.data['morea_id']}"
          else  # should be a prereq and so url is absolute.
            url = morea_page.data['morea_url']
          end
        end
      end
      if (url == "")
        puts "  Error: Could not find page or url corresponding to #{page_id}"
        site.config['morea_fatal_errors'] = true
      end
      if (url.end_with?("/"))
        url.chop!
      end
      return url
    end
  end
end

