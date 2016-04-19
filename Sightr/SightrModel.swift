class SightrModel {
    var guides = [Guide]()
    
    func createGuide(name:String) -> Int {
        // Save Guide
        let guide = Guide(name: name)
        guides.append(guide)
        
        // Get Index of created Guide
        let idx = guides.indexOf({ (currGuide:Guide) in
            if currGuide.id == guide.id {
                return true
            }
            
            return false
        })
        
        return idx!
    }
}