require 'selenium-webdriver'
#INFO: '#UTILS:' mark -- candidate for architectural OOP refactoring

#Class to store Freelancer's profile
class Freelancer
  @fcName
  @fcTitle
  @fcOverview
  @fcSkills
  @generalData

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
  def setGeneralData(genData)
    @generalData = genData
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
  def getGeneralData
    return @generalData
  end

end #Freelancer

@driver = nil
# Taking parameters from command line:
#!NOTE: Keyword should be a single word!
@keyword = nil
#--------------------------------------------------
#Data Structure to store found Freelancer's (Freelancer's search result):
@FcSearchResult = Array.new

#Incupsulating RandomIndex for @FcSearchResult usage only
@randomIndex = nil
#GETTER for RandomIndex (public function)
def getRandomIndex
  #NOTE: RandomIndex initialization is strongly depends of Freelancer's search result array!
  #puts "FcSearchResult Length: #{@FcSearchResult.length}" #DEBUG
  if @FcSearchResult.length > 0 then
    if @randomIndex.nil?  # should be initialized only once!
      @randomIndex = rand(@FcSearchResult.length)
      #puts "DEBUG: RandomIndex singleton has been made! Value = #{@randomIndex}" #DEBUG
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
  vendor = ARGV[1].to_s
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
  #exit(1)  #DEBUG: exit BUT without quit WebDriver.
end

#UTILS: can be moved to the independent UTILS module -- as possibly reusable code
# Test case: 5.  Enter <keyword> into the search input right from the drop-down and submit it
def testCase_5
  # (click on the magnifying glass button)
  puts "\nTest case: 5.  Enter '#{@keyword}' into the search input right from the drop-down and submit it"
  @driver.switch_to.active_element.send_keys(@keyword)  #pass <keyword> into focused element
  glass_button = @driver.find_elements(:class, 'p-0-left-right')[3]
  puts "Magnifying glass button was clicked: #{glass_button.click==nil ? 'Passed':'Failed'}"
  #exit(1)  #DEBUG: exit BUT without quit WebDriver.
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
      puts "#{index+1}.\telement - Saved"
      #p @FcSearchResult[index] #DEBUG: STDOUT - whole data
    }
    puts "All #{@FcSearchResult.length} elements are saved.\nPassed"
  else
    puts "No result with '#{@keyword}'! Try with another search keyword!\nFailed"
    testShutdown(1)
  end
  #exit(1)  #DEBUG: exit BUT without quit WebDriver.
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
    puts "General data contains: #{freelancer.getGeneralData.downcase.include?(@keyword.downcase)?'Passed':'Failed'}"
    #p freelancer #DEBUG: stdout
  }
  #exit(1)  #DEBUG: exit BUT without quit WebDriver.
end

# Build Freelancer object and grab data for it. (Builder and Grabber)
# Return: Freelancer instance
#TODO: belongs to Freelancer class - object creation
#TODO: BUT data-grabbing should be out of Freelancer class.
#TODO: Implement fetching data check - puts "Object id #{!not_nil_access.nil?}"
def createFreelancerObj (value)
  freelancer = Freelancer.new
  freelancer.setFcName(
      value.find_element(:class, 'display-inline-block').find_element(:class, 'freelancer-tile-name').text)
  freelancer.setFcTitle(value.find_element(:class, 'freelancer-tile-title').text)
  #INFO: [0] -- short overview; [1] -- full overview.
  not_nil_access = value.find_elements(:class, 'freelancer-tile-description')   # Check for NIL access.
  freelancer.setFcOverview(not_nil_access.length>1 ? not_nil_access[1].text : '' ) # value OR empty string as default
  freelancer.setFcSkills(
      value.find_elements(:class, 'o-tag-skill').map{ |skillEl| "'#{skillEl.text}'" }.join(","))

  freelancer.setGeneralData(value.text)
  return freelancer
end

# Test case: 8.  Click on random freelancer's title
def testCase_8
  puts "\nTest case: 8.  Click on random freelancer's title"
  # NOTE: If was clicked on Freelancers' TITLE - his name appears in browser title
  title_link = @driver.find_elements(:class, 'air-card-hover')[getRandomIndex]
                   .find_element(:class, 'display-inline-block').find_element(:class, 'freelancer-tile-name')
  # NOTE: If was clicked on section --- search result title will be displayed on the browser title.
  puts "Clicked on '#{@FcSearchResult[getRandomIndex].getFcName}' title: #{title_link.click.nil? ? 'Passed':'Failed'}"
  #exit(1)  #DEBUG: exit BUT without quit WebDriver.
end

# Test case: 9.  Get into that freelancer's profile
def testCase_9
  puts "\nTest case: 9.  Get into that freelancer's profile"
  puts "Browser title: #{@driver.title}"
  fc_name = @FcSearchResult[getRandomIndex].getFcName
  puts "Freelancer name: #{fc_name}"
  #TODO: Investigate maybe we can check here by base_url value of each freelancer in search-results
  puts "#{@driver.title.include?(fc_name)?'Passed':'Failed'}"
  #exit(1)  #DEBUG: exit BUT without quit WebDriver.
end

# Test case: 10. Check that each attribute value is equal to one of those stored in the structure created in #67
def testCase_10
  #TODO: move it to OOP approach.
  #TODO:#BUG Has problem with fetch data from companies profiles.
  #TODO:#BUG: Failed on - Freelancer Name:  MobiDev (keyword='javascript') --- it is company
  puts "\nTest case: 10. Check that each attribute value is equal to one of those stored in the structure created in TC6-7"
  puts "1) Freelancer Name:\n#{@FcSearchResult[getRandomIndex].getFcName}"
  @feJobTitleElem = @driver.find_elements(:class, 'fe-job-title')
  if @feJobTitleElem.length > 0 then
    @feJobTitleElem = @feJobTitleElem[0]
  else  # It's a company:
    @feJobTitleElem = @driver.find_elements(:tag_name, 'h3')[2]
  end
  #TODO:#BUG: undefined method `text' for nil:NilClass (NoMethodError) -- happens here (Freelancer Name:  Xavier P.)
  #TODO:#BUG: same problem happens here -- "Please verify you are a human" page - undefined method `text' for nil:NilClass (NoMethodError)
  puts "2) Freelancer's Job Title:\n#{@feJobTitleElem.text}"
  # !NOTE: Need more reliable element fetch, with multi class names!
  @feProfileOverview = @driver.find_element(:class, 'text-pre-line').text
  puts "3) Freelancer's Profile Overview:\n#{@feProfileOverview}"
  # Freelancer's Skills:
  puts "4) Freelancer's Skills:"
  @FeSkillsArray = @driver.find_elements(:class, 'o-tag-skill')
  @FeSkillsArray.each { |skill| puts skill.text }
  #TODO: Button 'more' hides a lot of info!
  puts "#{@driver.title.downcase.include?(@feJobTitleElem.text.downcase) ? 'Passed' : 'Failed'}"
  #TODO: fe (e.i. freelancer) -- should be an object
  #exit(1)  #DEBUG: exit BUT without quit WebDriver.
end

# Test case: 11. Check whether at least one attribute contains <keyword>
def testCase_11
  #TODO:#BUG: Failed on - Freelancer Name:  MobiDev (keyword='javascript')
  #TODO: move it to OOP approach.
  puts "\nTest case: 11. Check whether at least one attribute contains '#{@keyword}'"
  boolean_tc11 = false
  fc_name = @FcSearchResult[getRandomIndex].getFcName
  if fc_name.downcase.include?(@keyword.downcase)
    puts "Case: '#{@keyword}' contains in Freelancer's Name (#{fc_name})!"
    boolean_tc11 = true
  end
  if @feJobTitleElem.text.downcase.include?(@keyword.downcase)
    puts "Case: '#{@keyword}' contains in Freelancer's Job Title (#{@feJobTitleElem.text})!"
    boolean_tc11 = true
  end
  if @feProfileOverview.downcase.include?(@keyword.downcase)
    puts "Case: '#{@keyword}' contains in Freelancer's Overview (#{@feProfileOverview})!"
    boolean_tc11 = true
  end
  @FeSkillsArray.each { |skill|
    if skill.text.downcase.include?(@keyword.downcase)
      puts "Case: '#{@keyword}' contains in Freelancer's Skills!"
      boolean_tc11 = true
      break
    end
  }
  puts "#{(boolean_tc11 ? 'Passed' : 'Failed')}"
end

# End of the test.
def testEnd
  puts "\nTest was successfully passed!"
  testShutdown(0)
end

# Shutdown test with specified status, end quit browser. (gentle shutdown)
def testShutdown(status)
  @driver.quit
  puts "\nWebDriver was shutdown!"
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
testCase_7  #Status: Full Implementation - Done! (fixed: case insensitive check)
testCase_8  #Status: Full Implementation - Done!
testCase_9  #Status: Refactored
testCase_10 #Status: works - simple impl (Need refactoring) - bugs
testCase_11 #Status: works - simple impl (Need refactoring) - bugs
testEnd     #Status: Refactored