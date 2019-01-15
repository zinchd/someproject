require 'selenium-webdriver'
#INFO: '#UTILS:' mark -- candidate for architectural OOP refactoring

#Class to store Freelancer's profile
class Freelancer
  @fcName
  @fcTitle
  @fcOverview
  @fcSkills
  @fcGeneralData

  #SETTERS:
  def setFcName(fcName)
    @fcName = fcName
  end
  def setFcTitle(fcTitle)
    @fcTitle = fcTitle
  end
  def setFcOverview(fcOverview)
    @fcOverview = fcOverview
  end
  def setFcSkills(fcSkills)
    @fcSkills = fcSkills
  end
  def setFcGeneralData(fcGenData)
    @fcGeneralData = fcGenData
  end

  #GETTERS:
  def getFcName
    return @fcName
  end
  def getFcTitle
    return @fcTitle
  end
  def getFcOverview
    return @fcOverview
  end
  def getFcSkills
    return @fcSkills
  end
  def getFcGeneralData
    return @fcGeneralData
  end

  #TODO: Make general output method for Freelancer object. (like obj.toString())
end #Freelancer

NO_DATA = 'NO_DATA'
@driver = nil
# Taking parameters from command line:
#!NOTE: Keyword should be a single word!
@keyword = nil
#--------------------------------------------------
#Data Structure to store found Freelancer's (Freelancer's search result):
@FcSearchResult = Array.new
#Freelancer Object
@FcRandomProfile = nil

#Incupsulating RandomIndex for @FcSearchResult usage only
@randomIndex = nil
#GETTER for RandomIndex (public function)
def getRandomIndex
  #NOTE: RandomIndex initialization is strongly depends of Freelancer's search result array!
  #puts "FcSearchResult Length: #{@FcSearchResult.length}" #DEBUG
  if @FcSearchResult.length > 0 then
    if @randomIndex==nil  # should be initialized only once!
      # @randomIndex = rand(@FcSearchResult .length)
      @randomIndex = 8  #MobiDev  #DEBUG: specific index
      # @randomIndex = 14 #Codemotion  #DEBUG: specific index
      #puts "DEBUG: RandomIndex singleton has been made! Value = #{@randomIndex}" #DEBUG
      # Set DEFAULT value for Random Freelancer profile object:
      #@FcRandomProfile = @FcSearchResult[@randomIndex]
    end
    #puts "DEBUG: Returns RandomIndex! Value = #{@randomIndex}" #DEBUG
    return @randomIndex
  end
  puts "ERROR: FcSearchResult is not populated yet! Can't calculate RandomIndex on this moment!" #DEBUG
  return @randomIndex
end
#--------------------------------------------------

def testBegin
  puts "\nNOTE THAT: It's a search-engine test. NO validation. Quality of entered parameters are on YOUR side."
  if ARGV.length < 1
    puts "1st parameter required: Search Keyword (single word) should be passed!"
    puts "2nd parameter NOT required: Browser vendor 'chrome' or 'firefox' (by default)."
    exit(1)
  end
  @keyword = ARGV[0]
  puts "Search Keyword parameter: #{@keyword}"
  unless ARGV.length > 1
    puts "Browser parameter: can be set on 'chrome' or 'firefox'(by default)"
  end
end

# Test case: 1.  Run <browser>
def testCase_1
  @driver = Selenium::WebDriver
  vendor = ARGV[1].to_s.downcase
  puts "\nTest case: 1.  Run <browser>"
  puts "Browser parameter: #{vendor}"
  #TODO: code duplication --- do something with it
  if 'chrome'.eql?(vendor)
    @driver = @driver.for :chrome
    puts "INFO: #{@driver.browser.to_s.capitalize} browser was run"
    puts "#{@driver.browser.to_s.eql?('chrome') ? 'Passed':'Failed'}"
  else
    @driver = @driver.for :firefox
    puts "INFO: #{@driver.browser.to_s.capitalize} browser was run (by default)"
    puts "#{@driver.browser.to_s.eql?('firefox') ? 'Passed':'Failed'}"
  end
end

# Test case: 2.  Clear <browser> cookies
def testCase_2
  puts "\nTest case: 2.  Clear <#{@driver.browser}> cookies"
  puts "#{@driver.manage.delete_all_cookies==nil ? 'Passed':'Failed'}"
end

# Test case: 3.  Go to www.upwork.com
def testCase_3
  site = 'https://www.upwork.com'
  puts "\nTest case: 3.  Go to '#{site}'\n#{@driver.navigate.to(site)==nil ? 'Passed':'Failed'}"
end

#UTILS: can be moved to the independent UTILS module -- as possibly reusable code
# Test case: 4.  Focus onto "Find freelancers"
def testCase_4
  puts "\nTest case: 4.  Focus onto 'Find freelancers'"
  #!NOTE: elements' detection should be more flexible! (..[2].click -- array-index stub value.)
  @driver.find_elements(:class, 'dropdown-toggle')[2].click # Search drop-down was clicked
  search_elem = @driver.find_elements(:xpath, "//li[@data-label='Freelancers']")[2]
  puts "'Find #{search_elem.text}' search-mode was set: #{search_elem.click==nil ?'Passed':'Failed'}"
end

#UTILS: can be moved to the independent UTILS module -- as possibly reusable code
# Test case: 5.  Enter <keyword> into the search input right from the drop-down and submit it
def testCase_5
  # (click on the magnifying glass button)
  puts "\nTest case: 5.  Enter '#{@keyword}' into the search input right from the drop-down and submit it"
  @driver.switch_to.active_element.send_keys(@keyword)  #pass <keyword> into focused element
  glass_button = @driver.find_elements(:class, 'p-0-left-right')[3]
  puts "Magnifying glass button was clicked: #{glass_button.click==nil ? 'Passed':'Failed'}"
end

# Test case: 6.  Parse the 1st page with search results:
def testCase_6
  # store info given on the 1st page of search results as structured data of any chosen by you type
  # (i.e. hash of hashes or array of hashes, whatever structure handy to be parsed).
  puts "\nTest case: 6.  Parse the 1st page with search results:"
  fc_collection = @driver.find_elements(:class, 'air-card-hover')
  if fc_collection.length > 0
    #TODO: Population of FcSearchResult should be encapsulated!
    #Populate FcSearchResult array with Freelancer's objects:
    fc_collection.each_with_index {|value, index|
      @FcSearchResult[index] = createFreelancerObj(value)
      # puts "#DEBUG: #{index+1}.\telement - Saved" #DEBUG
      #p @FcSearchResult[index] #DEBUG: STDOUT - whole data
    }
    puts "All #{@FcSearchResult.length} elements are saved.\nPassed"
  else
    puts "No result with '#{@keyword}'! Try with another search keyword!\nFailed"
    testShutdown(1)
  end
end

# Test case: 7.  Make sure at least one attribute (title, overview, skills, etc) of each item
def testCase_7
  # (found freelancer) from parsed search results contains <keyword> Log in STDOUT which freelancers
  # and attributes contain <keyword> and which do not.
  puts "\nTest case: 7.  Make sure at least one attribute (title, overview, skills, etc)  of each item "
  puts "(found freelancer) from parsed search results contains '#{@keyword}' keyword Log in STDOUT which freelancers"
  puts "and attributes contain '#{@keyword}' keyword and which do not."
  @FcSearchResult.each_with_index {|freelancer, index|
    puts "------------------------------------------"
    puts "#{index+1}.\t '#{freelancer.getFcName}' check for keyword '#{@keyword}':"
    puts "Title contains: #{freelancer.getFcTitle.downcase.include?(@keyword.downcase)?'Passed':'Failed'}"
    puts "Overview contains: #{freelancer.getFcOverview.downcase.include?(@keyword.downcase)?'Passed':'Failed'}"
    puts "Skills contain: #{freelancer.getFcSkills.downcase.include?(@keyword.downcase)?'Passed':'Failed'}"
    puts "General data contains: #{freelancer.getFcGeneralData.downcase.include?(@keyword.downcase)?'Passed':'Failed'}"
    #p freelancer #DEBUG: stdout
  }
end

# Parsing Freelancer's profile
# Return: parsed_values array['name','job_title','profile_overview','skills','fc_gen_data']
def parseFreelancerProfile
  #TODO: implement 'general data' setting
  main = @driver.find_elements(:class, 'cfe-main') #main container
  if main.length > 0 then
    main = main[0]
  else  # its company
    main = @driver.find_element(:class, 'p-lg-left-right') #main container
  end
  p main  #DEBUG

  fc_name = main.find_element(:class, 'media-body').find_element(:tag_name, 'h2')
  # H2 inside: actual Name
  p fc_name
  fc_name = fc_name==nil ? NO_DATA : fc_name.text
  p "#DEBUG:Name: #{fc_name}" #DEBUG

  fc_job_title_elem = main.find_elements(:class, 'fe-job-title')
  if fc_job_title_elem.length > 0 then
    fc_job_title_elem = fc_job_title_elem[0]
  else  # its company
    fc_job_title_elem = main.find_elements(:tag_name, 'h3')
  end
  p "#DEBUG:Title: #{fc_job_title_elem}"  #DEBUG
  p "#DEBUG:Title[0]: #{fc_job_title_elem[0].text}" #DEBUG -- empty element
  p "#DEBUG:Title[1]: #{fc_job_title_elem[1].text}" #DEBUG -- actual title

  # if fc_job_title_elem==nil then
  #   #TODO: figure out BUGs with company data fetching
  #   fc_job_title_elem = @driver.find_elements(:tag_name, 'h3')[2]
  #   #TODO:BUG: solve it
  # end
  # fc_job_title = fc_job_title_elem==nil ? NO_DATA : fc_job_title_elem.text
  fc_job_title = fc_job_title_elem[1].text
  p "#DEBUG:Title: #{fc_job_title}"
  # exit(1)

  # Overview:
  fc_profile_overview = main.find_element(:class, 'text-pre-line').text
  p "#DEBUG:Overview: #{fc_profile_overview}"  #DEBUG
  # Freelancer's Skills:
  fc_skills = main.find_elements(:class, 'o-tag-skill').map {|skill| "'#{skill.text}'"}.join(',')
  p "#DEBUG:Freelancer's Skills: #{fc_skills}"  #DEBUG
  # General Data:
  fc_gen_data = main.text
  p "#DEBUG:General Data: #{fc_gen_data}"  #DEBUG

  #!NOTE: Not flexible approach. Strongly Fixed order! (use hash map OR )
  return fc_name, fc_job_title, fc_profile_overview, fc_skills, fc_gen_data
end

# Build Freelancer object and grab data for it. (Builder and Grabber)
# Return: Freelancer instance
#TODO: belongs to Freelancer class - object creation
#TODO: BUT data-grabbing should be out of Freelancer class.
#TODO: Implement fetching data check - puts "Object id #{!not_nil_access==nil}"
def createFreelancerObj (value)
  freelancer = Freelancer.new
  freelancer.setFcName(
      value.find_element(:class, 'display-inline-block').find_element(:class, 'freelancer-tile-name').text)
  freelancer.setFcTitle(value.find_element(:class, 'freelancer-tile-title').text)
  #INFO: [0] -- short overview; [1] -- full overview.
  not_nil_access = value.find_elements(:class, 'freelancer-tile-description')   # Check for NIL access.
  freelancer.setFcOverview(not_nil_access.length>1 ? not_nil_access[1].text : '' ) # value OR empty string as default
  #Convert Array into String separated by ','
  freelancer.setFcSkills(
      value.find_elements(:class, 'o-tag-skill').map{ |skillEl| "'#{skillEl.text}'" }.join(","))

  freelancer.setFcGeneralData(value.text)
  return freelancer
end

# Build Freelancer profile object and grab data for it. (Builder and Grabber)
# Return: Freelancer instance
def createFreelancerProfileObj (parsed_values)
  fc_profile = Freelancer.new
  fc_profile.setFcName(parsed_values[0])
  fc_profile.setFcTitle(parsed_values[1])
  fc_profile.setFcOverview(parsed_values[2])
  fc_profile.setFcSkills(parsed_values[3])
  fc_profile.setFcGeneralData((parsed_values[4]))
  # p fc_profile  #DEBUG
  puts "#DEBUG: Freelancer profile: #{fc_profile}"  #DEBUG
  return fc_profile
end

RELEVANT_MEMBER = 'Relevant agency member'
# Check for 'Relevant agency member' if it's some company
def isRelevantMember? (element)
  #puts "#DEBUG:isRelevantMember?: #{element.find_elements(:class, 'm-0-bottom')[2].text}"  #DEBUG
  return element.find_elements(:class, 'm-0-bottom')[2].text.include?(RELEVANT_MEMBER)
end
# Test case: 8.  Click on random freelancer's title
def testCase_8
  puts "\nTest case: 8.  Click on random freelancer's title"
  # NOTE: If was clicked on Freelancers' TITLE - his name appears in browser title
  puts "RandomIndex: #{getRandomIndex+1}"  #DEBUG:
  #TODO: parse 'Relevant agency member'
  title_link = @driver.find_elements(:class, 'air-card-hover')[getRandomIndex]  #find random element
  if isRelevantMember?(title_link) then # is company
    # 'Relevant agency member' Name link:
    title_link = title_link.find_elements(:class, 'm-0-bottom')[2].find_element(:class, 'm-xs-right')
    puts "Clicked on '#{title_link.text}' company member:"
  else
    title_link = title_link.find_element(:class, 'display-inline-block').find_element(:class, 'freelancer-tile-name')
    puts "Clicked on '#{@FcSearchResult[getRandomIndex].getFcName}' title:"
  end
  # NOTE: If was clicked on section --- search result title will be displayed on the browser title.
  puts title_link.click==nil ? 'Passed':'Failed'
end

# Test case: 9.  Get into that freelancer's profile
def testCase_9
  puts "\nTest case: 9.  Get into that freelancer's profile"
  fc_name = @FcSearchResult[getRandomIndex].getFcName
  puts "Browser title: '#{@driver.title}'"  #DEBUG
  puts " - CONTAINS ? -\nFreelancer's name: '#{fc_name}'"  #DEBUG
  #TODO: Investigate maybe we can check here by base_url value of each freelancer in search-results
  #Cover: 'Access to this page has been denied.'
  puts @driver.title.include?(fc_name) ? 'Passed' : testEndFailure
end

# Test case: 10. Check that each attribute value is equal to one of those stored in the structure created in #67
def testCase_10
  #TODO:#BUG Has problem with fetch data from companies profiles.
  #TODO:#BUG: Failed on - Freelancer Name:  MobiDev (keyword='javascript') --- it is company
  puts "\nTest case: 10. Check that each attribute value is equal to one of those stored in the structure created in TC6-7"

  #Freelancer's profile: Parsing DATA & Create object
  @FcRandomProfile = createFreelancerProfileObj(parseFreelancerProfile)

  #Standard Output:
  puts "1) Freelancer's Name:\n#{@FcRandomProfile.getFcName}"
  puts "2) Freelancer's Job Title:\n#{@FcRandomProfile.getFcTitle}"
  #TODO: Button 'more' hides a lot of info!
  puts "3) Freelancer's Profile Overview:\n#{@FcRandomProfile.getFcOverview}"
  puts "4) Freelancer's Skills:\n#{@FcRandomProfile.getFcSkills}"
  # puts "5)#DEBUG: Freelancer's General Data:\n#{@FcRandomProfile.getFcGeneralData}"

  #Checking:
  puts "\nChecking of equality between RandomFreelancer_Profile and RandomFreelancer_FromSearchResult:"
  puts "1) Freelancer's Name:\t\t"+
           "#{@FcRandomProfile.getFcName.downcase.include?(@FcSearchResult[getRandomIndex].getFcName.downcase) ? 'Passed':'Failed'}"
  puts "2) Freelancer's Job Title:\t"+
           "#{@FcRandomProfile.getFcTitle.downcase.include?(@FcSearchResult[getRandomIndex].getFcTitle.downcase) ? 'Passed' : 'Failed'}"
  puts "3) Freelancer's Overview:\t"+
           "#{@FcRandomProfile.getFcOverview.downcase.include?(@FcSearchResult[getRandomIndex].getFcOverview.downcase) ? 'Passed' : 'Failed'}"
  puts "4) Freelancer's Skills:\t\t"+
           "#{@FcRandomProfile.getFcSkills.downcase.include?(@FcSearchResult[getRandomIndex].getFcSkills.downcase) ? 'Passed' : 'Failed'}"
  puts "5)#DEBUG: Freelancer's General Data:\t\t"+
           "#{@FcRandomProfile.getFcGeneralData.downcase.include?(@FcSearchResult[getRandomIndex].getFcGeneralData.downcase) ? 'Passed' : 'Failed'}"
end

# Test case: 11. Check whether at least one attribute contains <keyword>
def testCase_11
  #TODO:#BUG: Failed on - Freelancer Name:  MobiDev (keyword='javascript')
  puts "\nTest case: 11. Check whether at least one attribute contains '#{@keyword}'"
  boolean_tc11 = false

  if @FcRandomProfile.getFcName.downcase.include?(@keyword.downcase)
    puts "Case-1. '#{@keyword}' contains in Freelancer's Name:\n#{@FcRandomProfile.getFcName}"
    boolean_tc11 = true
  end
  if @FcRandomProfile.getFcTitle.downcase.include?(@keyword.downcase)
    puts "Case-2. '#{@keyword}' contains in Freelancer's Job Title:\n#{@FcRandomProfile.getFcTitle}"
    boolean_tc11 = true
  end
  if @FcRandomProfile.getFcOverview.downcase.include?(@keyword.downcase)
    puts "Case-3. '#{@keyword}' contains in Freelancer's Overview:\n#{@FcRandomProfile.getFcOverview}"
    boolean_tc11 = true
  end
  if @FcRandomProfile.getFcSkills.downcase.include?(@keyword.downcase)
    puts "Case-4. '#{@keyword}' contains in Freelancer's Skills:\n#{@FcRandomProfile.getFcSkills}"
    boolean_tc11 = true
  end
  if @FcRandomProfile.getFcGeneralData.downcase.include?(@keyword.downcase)
    puts "DEBUG:Case. '#{@keyword}' contains in Freelancer's General Data:"
  end
  puts boolean_tc11 ? 'Passed' : 'Failed'
end

# End of the test.
def testEnd
  puts "\nTest was successfully PASSED!"
  testShutdown
end
# Gentle End of the test in case of failure scenario. (with Notification and WebDriver quit)
def testEndFailure
  puts 'Failed'
  puts "\nTest was ended with FAILURE!"
  testShutdown(1)
end

# Shutdown test with specified status, end quit browser. (gentle shutdown)
## status: 0 - success;
### 1 - gentle exit with WebDriver quit. #DEBUG
### 2 - force exit with WebDriver interruption.  #DEBUG
def testShutdown(status = 0)
  if status >= 2
    puts "\nWebDriver was interrupted!"
  else
    @driver.quit
    puts "\nWebDriver was shutdown!"
  end
  exit(status)
end

# Main test-scenario:
testBegin   #Status: Refactored
testCase_1  #Status: Refactored
testCase_2  #Status: Full Implementation - Done!
testCase_3  #Status: Full Implementation - Done!
testCase_4  #Status: Full Implementation - Done!
testCase_5  #Status: Full Implementation - Done!
testCase_6  #Status: Full Implementation - Done!
testCase_7  #Status: Full Implementation - Done!
testCase_8  #Status: Full Implementation - Done!
testCase_9  #Status: Full Implementation - Done!
testCase_10 #Status: Rough Implementation - Done! Refactoring [80%]
testShutdown(2)  #DEBUG: force exit with WebDriver interruption.
testCase_11 #Status: Rough Implementation - Done! Refactoring [80%]
testEnd     #Status: Refactored
# testShutdown(1)  #DEBUG: gentle exit with WebDriver quit.


#TODO: BUG-Cases:
# 50.	 'Croma' check for keyword 'javascript':
# Title contains: Failed
# Overview contains: Failed
# Skills contain: Failed
# General data contains: Passed