import 'package:flutter/material.dart'; // Import the Flutter Material package for UI components
import 'package:http/http.dart'
    as http; // Import the HTTP package for making network requests
import 'dart:convert'; // Import dart:convert for JSON encoding/decoding

// Constants for API keys
const String tmdbApiKey = 'c803fcd6c9b4ac0125223d11ef45e7b1'; // TMDb API Key
const String clientId = '6752c32f79404a7bba5e5ef1eac59a96'; // Spotify Client ID
const String clientSecret =
    'fe14dabba842419cb671da8e12fc7e3b'; // Spotify Client Secret

// Main entry point of the application
void main() => runApp(MyApp()); // Runs the MyApp widget

// MyApp widget that serves as the root of the application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie and Artist Search App', // Title of the application
      theme: ThemeData(primarySwatch: Colors.blue), // Theme settings
      home: LoginPage(), // Set the initial route to the login page
    );
  }
}

// LoginPage widget for user authentication
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() =>
      _LoginPageState(); // Create the state for this widget
}

// State for the LoginPage
class _LoginPageState extends State<LoginPage> {
  final _formKey =
      GlobalKey<FormState>(); // Key for the form to manage its state
  final _usernameController =
      TextEditingController(); // Controller for username input
  final _passwordController =
      TextEditingController(); // Controller for password input

  // Function to handle login
  void _login() {
    if (_formKey.currentState?.validate() == true) {
      // Validate the form
      Navigator.pushReplacement(
        // Navigate to the selection screen on successful login
        context,
        MaterialPageRoute(
            builder: (context) =>
                SelectionScreen()), // Navigate to SelectionScreen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')), // App bar with title
      body: Padding(
        padding: EdgeInsets.all(16.0), // Padding around the form
        child: Form(
          // Form widget
          key: _formKey, // Assign the form key
          child: Column(
            // Column to arrange form fields vertically
            mainAxisAlignment: MainAxisAlignment.center, // Center the column
            children: <Widget>[
              // Children of the column
              TextFormField(
                controller: _usernameController, // Set controller for username
                decoration: InputDecoration(
                    labelText: 'Username or Email'), // Input decoration
                validator: (value) {
                  // Validator for username input
                  if (value == null || value.isEmpty) {
                    // Check for empty value
                    return 'Please enter your username or email'; // Error message
                  }
                  return null; // Return null if valid
                },
              ),
              TextFormField(
                controller: _passwordController, // Set controller for password
                decoration:
                    InputDecoration(labelText: 'Password'), // Input decoration
                obscureText: true, // Mask the password input
                validator: (value) {
                  // Validator for password input
                  if (value == null || value.isEmpty) {
                    // Check for empty value
                    return 'Please enter your password'; // Error message
                  }
                  return null; // Return null if valid
                },
              ),
              SizedBox(height: 20), // Space between inputs and button
              ElevatedButton(
                onPressed: _login, // Call _login on button press
                child: Text('Login'), // Button label
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SelectionScreen widget for choosing between APIs
class SelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select API')), // App bar with title
      body: Center(
        child: ApiSelectionWidget(), // Custom widget for API selection
      ),
    );
  }
}

// ApiSelectionWidget for displaying API options
class ApiSelectionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      // Column to arrange buttons vertically
      mainAxisAlignment: MainAxisAlignment.center, // Center the column
      children: [
        ElevatedButton(
          onPressed: () {
            // When the TMDb button is pressed
            Navigator.push(
              // Navigate to MovieSearchScreen
              context,
              MaterialPageRoute(builder: (context) => MovieSearchScreen()),
            );
          },
          child: Text('Search Movies (TMDb)'), // Button label
        ),
        SizedBox(height: 20), // Space between buttons
        ElevatedButton(
          onPressed: () {
            // When the Spotify button is pressed
            Navigator.push(
              // Navigate to ArtistSearchScreen
              context,
              MaterialPageRoute(builder: (context) => ArtistSearchScreen()),
            );
          },
          child: Text('Search Artists (Spotify)'), // Button label
        ),
      ],
    );
  }
}

// MovieSearchScreen widget for searching movies
class MovieSearchScreen extends StatefulWidget {
  @override
  _MovieSearchScreenState createState() =>
      _MovieSearchScreenState(); // Create state for movie search
}

// State for MovieSearchScreen
class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final TextEditingController _controller =
      TextEditingController(); // Controller for movie name input
  String? _movieInfo; // Variable to hold movie information
  String? _moviePoster; // Variable to hold movie poster URL
  bool _isLoading = false; // Loading state

  // Function to fetch movie information
  Future<void> _getMovieInfo(String movieName) async {
    setState(() {
      _isLoading = true; // Set loading state to true
      _movieInfo = null; // Clear previous movie info
      _moviePoster = null; // Clear previous poster
    });

    final response = await http.get(
      // Fetch movie data from TMDb API
      Uri.parse(
          'https://api.themoviedb.org/3/search/movie?api_key=$tmdbApiKey&query=$movieName'),
    );

    if (response.statusCode == 200) {
      // Check for successful response
      final Map<String, dynamic> data =
          json.decode(response.body); // Decode JSON response
      if (data['results'].isNotEmpty) {
        // Check if results are not empty
        final movie = data['results'][0]; // Get the first movie result
        setState(() {
          _movieInfo =
              'Title: ${movie['title']}\n' // Construct movie info string
              'Year: ${movie['release_date']?.split('-')[0]}\n' // Extract release year
              'Overview: ${movie['overview']}'; // Get movie overview
          _moviePoster = movie['poster_path'] !=
                  null // Check if poster path is available
              ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}' // Construct full poster URL
              : null; // No poster available
        });
      } else {
        setState(() {
          _movieInfo = 'Movie not found.'; // No movies found
        });
      }
    } else {
      print('Error fetching movie info: ${response.statusCode}'); // Log error
      setState(() {
        _movieInfo =
            'Failed to fetch movie info.'; // Failed to fetch movie info
      });
    }

    setState(() {
      _isLoading = false; // Set loading state to false
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie Search - TMDb'), // App bar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the content
        child: Column(
          children: [
            TextField(
              controller: _controller, // Set controller for the text field
              decoration: InputDecoration(
                labelText: 'Enter movie name', // Input label
                border: OutlineInputBorder(), // Input border style
              ),
            ),
            SizedBox(height: 20), // Space between text field and button
            ElevatedButton(
              onPressed: () {
                // When search button is pressed
                if (_controller.text.isNotEmpty) {
                  // Check if input is not empty
                  _getMovieInfo(_controller.text); // Fetch movie info
                }
              },
              child: Text('Search'), // Button label
            ),
            SizedBox(height: 20), // Space between button and results
            if (_isLoading)
              CircularProgressIndicator(), // Show loading indicator if fetching
            if (_movieInfo != null)
              Text(
                _movieInfo!, // Display fetched movie info
                textAlign: TextAlign.left, // Align text to the left
              ),
            if (_moviePoster != null)
              Image.network(
                _moviePoster!, // Load movie poster image from URL
                width: 100, // Set desired width
                height: 150, // Set desired height
                fit:
                    BoxFit.cover, // Adjust how the image fits within the bounds
              ),
          ],
        ),
      ),
    );
  }
}

// ArtistSearchScreen widget for searching artists
class ArtistSearchScreen extends StatefulWidget {
  @override
  _ArtistSearchScreenState createState() =>
      _ArtistSearchScreenState(); // Create state for artist search
}

// State for ArtistSearchScreen
class _ArtistSearchScreenState extends State<ArtistSearchScreen> {
  final TextEditingController _controller =
      TextEditingController(); // Controller for artist name input
  String? _artistInfo; // Variable to hold artist information
  List<String> _topTracks = []; // List to hold top tracks
  String? _artistImage; // Variable to hold artist image URL
  bool _isLoading = false; // Loading state

  // Function to fetch Spotify access token
  Future<String?> _getSpotifyAccessToken() async {
    final String credentials = base64Encode(
        utf8.encode('$clientId:$clientSecret')); // Encode client ID and secret

    final response = await http.post(
      // Request access token from Spotify API
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization':
            'Basic $credentials', // Authorization header with encoded credentials
        'Content-Type':
            'application/x-www-form-urlencoded', // Content type header
      },
      body: {
        'grant_type': 'client_credentials', // Grant type for access token
      },
    );

    if (response.statusCode == 200) {
      // Check for successful response
      final Map<String, dynamic> data =
          json.decode(response.body); // Decode JSON response
      return data['access_token']; // Return the access token
    } else {
      print('Failed to get access token: ${response.statusCode}'); // Log error
      return null; // Return null if failed
    }
  }

  // Function to fetch artist information and top tracks
  Future<void> _getArtistAndTopTracks(String artistName) async {
    setState(() {
      _isLoading = true; // Set loading state to true
      _topTracks = []; // Clear previous top tracks
    });

    final accessToken = await _getSpotifyAccessToken(); // Fetch access token
    if (accessToken == null) return; // Exit if token fetch failed

    final artistResponse = await http.get(
      // Fetch artist data from Spotify API
      Uri.parse(
          'https://api.spotify.com/v1/search?q=$artistName&type=artist&limit=1'),
      headers: {
        'Authorization':
            'Bearer $accessToken', // Set authorization header with access token
      },
    );

    if (artistResponse.statusCode == 200) {
      // Check for successful response
      final Map<String, dynamic> artistData =
          json.decode(artistResponse.body); // Decode JSON response
      if (artistData['artists']['items'].isNotEmpty) {
        // Check if artist found
        final artist =
            artistData['artists']['items'][0]; // Get the first artist result
        final artistId = artist['id']; // Get the artist's ID
        _artistImage = artist['images'].isNotEmpty
            ? artist['images'][0]['url']
            : null; // Get artist image if available

        setState(() {
          _artistInfo =
              'Artist: ${artist['name']}\n' // Construct artist info string
              'Followers: ${artist['followers']['total']}\n' // Get follower count
              'Genres: ${artist['genres'].join(', ')}\n' // Get genres
              'Popularity: ${artist['popularity']}'; // Get popularity score
        });

        await _getTopTracks(
            artistId, accessToken); // Fetch top tracks for the artist
      } else {
        setState(() {
          _artistInfo = 'No artist found.'; // No artist found message
        });
      }
    } else {
      print(
          'Error fetching artist info: ${artistResponse.statusCode}'); // Log error
    }

    setState(() {
      _isLoading = false; // Set loading state to false
    });
  }

  // Function to fetch top tracks of the artist
  Future<void> _getTopTracks(String artistId, String token) async {
    final topTracksResponse = await http.get(
      // Fetch top tracks from Spotify API
      Uri.parse(
          'https://api.spotify.com/v1/artists/$artistId/top-tracks?market=US'), // API endpoint
      headers: {
        'Authorization':
            'Bearer $token', // Set authorization header with access token
      },
    );

    if (topTracksResponse.statusCode == 200) {
      // Check for successful response
      final Map<String, dynamic> tracksData =
          json.decode(topTracksResponse.body); // Decode JSON response
      _topTracks = List<String>.from(tracksData['tracks']
          .map((track) => track['name'])); // Get track names
      setState(() {}); // Trigger a rebuild to show the top tracks
    } else {
      print(
          'Error fetching top tracks: ${topTracksResponse.statusCode}'); // Log error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artist Search - Spotify'), // App bar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the content
        child: Column(
          children: [
            TextField(
              controller: _controller, // Set controller for the text field
              decoration: InputDecoration(
                labelText: 'Enter artist name', // Input label
                border: OutlineInputBorder(), // Input border style
              ),
            ),
            SizedBox(height: 20), // Space between text field and button
            ElevatedButton(
              onPressed: () {
                // When search button is pressed
                if (_controller.text.isNotEmpty) {
                  // Check if input is not empty
                  _getArtistAndTopTracks(
                      _controller.text); // Fetch artist info and top tracks
                }
              },
              child: Text('Search'), // Button label
            ),
            SizedBox(height: 20), // Space between button and results
            if (_isLoading)
              CircularProgressIndicator(), // Show loading indicator if fetching
            if (_artistInfo != null)
              Text(
                _artistInfo!, // Display fetched artist info
                textAlign: TextAlign.left, // Align text to the left
              ),
            if (_artistImage != null)
              Image.network(
                _artistImage!, // Load artist image from URL
                width: 100, // Set desired width
                height: 100, // Set desired height
                fit:
                    BoxFit.cover, // Adjust how the image fits within the bounds
              ),
            SizedBox(height: 20), // Space between image and top tracks
            if (_topTracks.isNotEmpty)
              Text(
                'Top Tracks:', // Title for top tracks
                style: TextStyle(fontWeight: FontWeight.bold), // Bold style
              ),
            for (var track in _topTracks) // Loop through each top track
              Text(track), // Display track name
          ],
        ),
      ),
    );
  }
}