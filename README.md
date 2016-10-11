# upload-api

This is a proof of concept.  It is the endpoint to our client-side Flow JS proof of concept.  The meat of the code is based off of the Ruby backend code [from flow.js](https://github.com/flowjs/flow.js/tree/master/samples) The endpoint accepts file chunks and when it gets the last chunk, it concatenates all the files together into one final file and returns a checksum of the final file.

This API has been deployed to an AWS beanstalk instance.  Ask the developer for details of the beanstalk.