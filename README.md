<h1>Bookmark Manager</h1>

## Table of Contents

* [App Screenshots](#app-screenshots)
* [General Description](#general-description)
* [Browser Caveate](#browser-caveate)
* [Testing](#testing)


## App Screenshots

![](public/images/screenshot.png "app_screenshot_1")

<br/>

![](public/images/screenshot.png "app_screenshot_2")


##  General Description

<p><strong>Bookmark Manager</strong> is a simple Sinatra web application that allows users 
to create and save a list of links (or 'bookmarks') to various websites, as well as categorize 
and filter them via tags.</p>

<p>At the heart of the app is a postgresql database, whereas the front-end of the app was 
created as an exercise in buiding a fully functional Sinatra web application in TDD. 
As such, the app comes with a comprehensive testing suite with integration and feature 
tests for all models and webpages.</p> 

<p>The app includes a user management interface that allows users to sign up,
sign in and sign out. In this context, various validations have been put in place, e.g.
verification of correct email format, email uniqueness, password length, and so forth.</p>

<p>Registered users can add new bookmarks to the list, while un-registered visitors can only 
view its corrent content.</p>

<p>When adding a new bookmark, the user is prompted to provide a url address, a title, as well as
optional tags for indexing purposes.</p>

<p>The list itself can be viewed in its entirety (the defualt), or it can be filtered according
to a specific tag. Both the list itself and the tags are ordered alphabetically.</p>

<p>In visual terms, the site includes a 'sticky' navigation bar at the top, and a 'sticky' footer at
the bottom.</p>


##  Browser Caveate

<p>Please note that this app has been optimized primarily for <strong>Google Chrome</strong>, 
and to a lesser extent <strong>Apple Safari</strong>. The app uses flexbox to display 
various element, and despite my efforts to make it suitable for other browsers as well, 
it may not look as intended on them.</p>


##  Testing

<p>Tests were written with Rspec & Capybara.</p>

<p>To run the tests in terminal: $ rspec</p>

<p>Rspec version: 3.0.3</p>

<p>Capibara version: 2.3.0</p>
