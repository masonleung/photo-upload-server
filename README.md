# Photo upload server

Allows user to load a photo and returns photo metadata and quality score

## Design overview
The simplest implementation is a single endpoint in the application that calls a photo processor and returns photo metadata and quality score.  However, this setup does not scale and locks up resources.

The current photo uplaod server has two main endpoints.

**/upload**

 It shows a phot upload form.  When a photo is uploaded, it puts a message in a queue and displays a page with metadata and quality score.  The page makes a AJAX request every second to get photo data.  A backend photo processor runs in a loop to get message out of the queue for processing.  The result is stored in a database.

**/quality/jpeg/:image_name**

It returns photo metadata and quality score in a json blob (status code 200) or no content (status code 204)

The uploaded photo is renamed from **photo.jpg** to **'epoch_time'_photo.jpg** to avoid duplicate file name

### Advantages of this design
- Web servers can scale
- Backend photo processor can scale
- User does not lock up web server process

## System requirements
* Operating System: Ubuntu 12.04 LTS
* Database: sqlite3
* Framework: Sinatra
* Queue: RabbitMQ
* Language: ruby 2.1.2
* Misc: rvm

## To Run

        # install rabbitmq server
        apt-get install rabbitmq-server

        # install ImageMagick
        apt-get install imagemagick libmagickwand-dev

        # install rvm
        \curl -sSL https://get.rvm.io | bash -s stable

        # install ruby 2.1.2
        rvm install 2.1.2

        # use ruby 2.1.2
        rvm use 2.1.2

        # install gems
        bundle install

        # do database migration
        rake db:migrate

        # start server
        shotgun -o 0.0.0.0

        # start photo processor
        rake utils:photo_processor

## Issues encountered/lessons learned
### Don't pick a technology by hype
I debated whether to use **ruby-vips** or **rmagick** to process photo.  From researching, the **ruby-vips** gem was supposed to be more lightweighted and no memory leak.  However, I found very little documentation about this gem.  After fiddling a few hours trying to get the photo metadata, I switched to **rmagick**.  It was much easier to use, the documentation and exmples were abundant.

### Raking it in
The photo processor was not tied into the application and I tried to figure out how to load the model and queue.  I wanted to avoid doing **require** everywhere.  As I was doing the db migration, why not set up the photo processor as a rake task.  It simplies the dependency I have to bring in and **rake -T** lets me put a description about the task

### Separation of view and data
The **/quality/jpeg/:image_name** returns 204 **(nocontent)** when the requested image does not existed or has not been or failed to process.  I thought about returning 200 with an error message in json blob, but returning 204 is more appropriate and the frontend template can display error message accordingly

### JQuery is your friend
I have not used jQuery before and found it surprizingly useful.  The documentation was very clear, there are a lot of examples.  It makes the AJAX request much easier to deal with than expected

### Make user feel in control
The page after a photo is uploaded display current status.  It adds a **.** to the end of the message until the AJAX call is done and times out after 50 seconds.  This gives user an indicator that the photo is being processed and works are being done while waiting

## Photo quality calculation
### Methods implemented
#### Grid sampling (Preferred)
Divide the image into a 10x10 grid and look at the color level in each grid.  Sum the color level and do logarithmic on the number for normalization.  The idea is to identify photo with more colors.  The caveat of this approach is coming up with a normalized scale which I have not figured out yet.  Regardless, this method is better than the other I have tried.  See the **preferred method** section on why it is selected

#### Composite standard deviation distance
Modify the image by **sharpening**, **normalization**, and **equalization** and calculate score by adding the difference of standard deviations between original image and modified image.  The motivation is the modified images are more optimal and better quality.  Therefore, the smaller the standard deviation difference is, the closer the original image is to the optimal

#### Overlay image
Overlay image with different backgrounds and check opacity with the hope that higher opacity result in less colors (because colors fade into the background and reduce standard deviation).  This approach did not work well because there are too many backgrounds to test.  I spent a lot of time getting the overlay to work and was not worth the effort

#### DPI
Score based on the product of x and y resolutions.  This approach is very simple, but only show whether the image is high resolution or not

### Preferred Method
Grid sampling is preferred because it breaks the photo into smaller grids and check them individually.  This method identifies pictures with higher color depth and gives lower score to pictures with large mono color background with an item in the middle.  This gives indication to users that they should crop the image (therefore reduce image size) to make the item larger in the photo, so more focus is on the item

## Testing (TODO)
Use rspec to test endpoints and the photo processor.  Look into vcr and factorgirl to mock http response and database model.  Need to really think about breaking this down into components when running tests.  Don't want to end up doing multiple end to end tests, that break easily because it test too many components at once

## TODO
* Add tests
* Add endpoint to display photo
* Better photo quality calculation
* Better UI, only display simple photo metadata, quality score and message
