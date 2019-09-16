        webView.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, request: WebResourceRequest?): Boolean {

                // Detect CityMotion specific links for handling
                if (request?.url != null) {
                    val checkUrl = request.url.toString()
                        // Else: this navigates all universal links via Intent to Chrome or prompts the installed app
                        try {
                            println("External Link Navigate: " + request.toString())
                            val intent = Intent(Intent.ACTION_VIEW)
                            if (checkUrl.contains("CM_UNIVERSAL_LINK")) {
                                // Load and read the universal link
                                intent.data = request.url
                                startActivity(intent)
                            } else if (checkUrl.contains("CM_URI")) {
                                // URI: Try to directly open the local app
                                intent.data = Uri.parse(checkUrl)
                                startActivity(intent)
                            }
                        } catch (e: ActivityNotFoundException) {
                            println("External Link Unreachable: " + e.toString())
                            // If URI fails try to open Google Play
                            val regex = Regex(pattern = "(?<=CM_URI=).*\$")
                            val match = regex.find(checkUrl)?.value
                            if (match.isNotEmpty()) {
                                intent.data = Uri.parse(match)
                                startActivity(intent)
                            }
                        }
                        // Return true for all CM links means unreachable URI links are safely ignored
                        return true
                }

                // Otherwise all links are navigated inside the WebView
                return false
            }
        }