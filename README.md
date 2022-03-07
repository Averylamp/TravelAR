# TravelAR

[_See Our Devpost_](https://devpost.com/software/travelar-g4sq6y)

<a href="https://www.youtube.com/watch?v=ACneUIVByaY&index=2&list=PLyC3kmCiJ2x31ZLjuB7RogEvyamrkSOo9">
  <h3> 
    <a href="https://www.youtube.com/watch?v=ACneUIVByaY&index=2&list=PLyC3kmCiJ2x31ZLjuB7RogEvyamrkSOo9">
      View the full video 
    </a>
  </h3>
<img alt="Youtube Video Preview" src="https://user-images.githubusercontent.com/7774592/156963568-7ecccc0a-cf25-48f5-a55b-f7539626fa11.gif">
</a>

![alt tag](https://raw.githubusercontent.com/Averylamp/TravelAR/master/Images/screen1.jpg)


Traveling is exciting - planning, not so much. We thought about different ways to improve the vacation search process and found that visuals were key in selecting the perfect location. Because of this, we created TravelAR, an augmented reality app that allows you to physically step into scenes of different cities, then find flight information if you have found your ideal travel destination.

![alt tag](https://raw.githubusercontent.com/Averylamp/TravelAR/master/Images/screen2.jpg)

## What it does
TravelAR is an iOS travel application built using Apple's ARKit. On opening the app, there is a camera view in the room. Upon tapping, there will be an augmented reality "portal" to another city, where you physically walk inside another "room" and view a gallery of AR scenes from the city. If interested in travel information to the city, there is a pull-up information section where a user can find relevant flight details and prices.

![alt tag](https://raw.githubusercontent.com/Averylamp/TravelAR/master/Images/screen3.jpg)

## How we built it
We built TravelAR with Apple's iOS ARKit, a Flask server hosted with Microsoft Azure, and many APIs including the Amadeus Travel APIs, the Microsoft Bing Image Search API, and the WolframAlpha Simple API. The iOS application submits a “GET” request to our Flask server hosted in the cloud with Microsoft Azure. This Flask server takes in a city/location name, and it processes that string with many APIs to extract information—starting with the Amadeus Travel APIs. We hit the Amadeus endpoints with our location to gather information on popular attractions nearby, flight statistics, and other general travel information. We then port the “popular attractions” into the Microsoft Bing Image Search API to get a list of image urls that will be displayed in the iOS application. Furthermore, we use the WolframAlpha API to get information on the population. We combine all of the information with the AR to create a comprehensive visual display with helpful information.

![alt tag](https://raw.githubusercontent.com/Averylamp/TravelAR/master/Images/screen4.jpg)

## What's next for TravelAR
The future vision for TravelAR is creating 3d scenes that are almost indistinguishable from reality. Imagine stepping into the "Paris" portal and being able to view in 3d detail all things around you, the interactions of the community, and experience all of the tourist attractions - right from your home.  We would also want to expand this experience by making it social. It would be great to see which of your friends have traveled to a particular location in the past and also to take inspiration from other people's travel experiences.


#### Travel information by APIs

Amadeus APIs
- popular sites/destinations
- lat / lon
- airport and airport code
- flight info: 3x for the next three weeks each with list of 10 [price, currency, airline, time of day]

Microsoft Bing Image Search API
- images of popular sites (as determined by Amadeus API)

WolframAlpha API
- population


Made by: Avery Lamp, Ethan Weber, Arlene Siswanto, Kenneth Friedman

---
If you would like to see more things that I (Avery Lamp) has made, check out my:

[_Devpost_](http://devpost.com/averylamp)

[_Website_](http://averylamp.me)

[_Youtube_](https://www.youtube.com/playlist?list=PLyC3kmCiJ2x31ZLjuB7RogEvyamrkSOo9)

If you would like to get in contact with me, here is my [_resume_](http://averylamp.me/Resume.pdf)
