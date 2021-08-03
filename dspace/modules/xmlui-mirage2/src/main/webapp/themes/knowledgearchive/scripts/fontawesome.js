import { library, dom } from '@fortawesome/fontawesome-svg-core'
import { faRss, faAt, faEnvelope } from '@fortawesome/free-solid-svg-icons'
import { faFacebook, faTwitter, faLinkedin, faOrcid } from '@fortawesome/free-brands-svg-icons'

// Add solid icons to our library
library.add(faRss, faAt, faEnvelope)

// Add brand icons to our library
library.add(faFacebook, faTwitter, faLinkedin, faOrcid)

// Replace any existing <i> tags with <svg> and set up a MutationObserver to
// continue doing this as the DOM changes.
dom.watch()
