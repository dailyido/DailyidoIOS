-- Wedding Tips Import for Supabase
-- Generated: 2026-01-22T11:41:27.014625
-- Total rows: 496

-- First, clear existing data (optional - comment out if you want to keep existing)
-- DELETE FROM wedding_tips;

-- Insert all tips
INSERT INTO wedding_tips (
    id, category, specific_day, title, tip_text, priority,
    month_category, fun_tip, has_illustration, illustration_url,
    affiliate_button_text, affiliate_url, on_checklist, wedding_type,
    is_active, created_at
) VALUES
(
    '38d96ea1-a2ea-4425-9c97-049d64fdbd6d', 'Beginning', 440, 'Have the Big-Picture Talk', 'Sit down together and talk vision: size, season, vibe, budget range, what matters most, and what doesn’t matter at all. This is you''re wedding North Star.', 1,
    '12+ months', false, true, '56.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '1562e47d-0a05-4181-b1f2-d0a620bbe0e7', 'Beginning', 439, 'Decide Your Top 3 Priorities', 'Pick the three areas you REALLY care about (photography, food, venue, band, florals, etc.). This helps guide all future spending decisions.', 1,
    '12+ months', false, true, 'checklist.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '01a01b9d-1bef-4a85-be28-c5898b3f4340', 'Planning & Organization', 438, 'Create a Shared Wedding Email', 'Make a separate email address for quotes, vendor contracts, and confirmations. Saves your sanity and inbox searching later.', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '6c3a76cf-1c6f-459c-ba24-3471655e98d2', 'Guest Experience', 437, 'Draft a Rough Guest Count', 'Not a final list-just an approximate number. Guest count drives everything: venue options, budget, catering costs.', 1,
    '12+ months', false, true, '181.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '8705706a-691c-4e5d-931e-b953a128478f', 'Blank Fun Fact', 436, NULL, NULL, NULL,
    '12+ months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '9886df1a-bca0-4320-953c-ba9bbe3c1651', 'Design', 435, 'Dream Board Time!', 'Pinterest, Instagram, TikTok… go wild. Save anything that feels like “you.” Patterns will emerge.', 1,
    '12+ months', false, true, 'Wedding Icon 108.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '6260b0cf-984a-4e60-add5-35e2b25d16d8', 'Budget', 434, 'Identify Your Budget Contributors', 'Have the sometimes-awkward conversation with anyone contributing financially. Clear expectations now = fewer surprises later.', 1,
    '12+ months', false, true, 'dollar_sign.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '18a1a1b0-c091-410b-855e-50a5c9b72f09', 'Beginning', 433, 'Let''s Find Your Dream Venue!', 'Are we booking a seaside ceremony, or a mountain top soiree? We love them all. Make Sure you are asking your venue all the questions - including the all in cost.', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '9702439c-14ad-4e44-a8db-e1655e8e192b', 'Venue', 432, 'Negotiate Pricing with Your Venue', 'Make sure you are asking them for concessions, like a complimentary late night snack or an extra hour of dancing. It''s always worth the ask, you''ll be surprised what you can get.', 1,
    '12+ months', false, false, 'dollar_sign.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '1198e5b4-1b87-40b5-9c20-b5e3a012c078', 'Venue', 431, 'Set Your Ideal Location', 'Beach, barn, ballroom, or backyard - near or far from home. Start narrowing your options.', 1,
    '12+ months', false, true, '56.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'fe44ccb1-15d5-4d55-ac89-0927a504b43a', 'Beginning', 430, 'Make Sure You Are Asking for Full Quotes', 'When looking at venues or catering teams, make sure you are asking for full quotes including tax, gratuity, and admin fees. There is nothing worse than surprise fees at the end of planning.', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '5591bbb3-0914-4133-a013-15fbd8624677', 'Planning & Organization', 429, 'Hire a Wedding Planner or Coordinator', 'A wedding planner is completely different from your venue or catering manager. This is the time to bring a pro in before big decisions start rolling.', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'e9111f76-3963-48ac-978f-e30c8ba0fd38', 'Planning & Organization', 428, 'Create a Shared Planning Doc', 'Google Sheet, shared note, or an app - track budget, vendor options, guest addresses, and timelines.', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '59e5f177-b85b-48ae-aa20-f2493f96e008', 'Blank Fun Fact', 427, NULL, NULL, NULL,
    '12+ months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '968ff6e2-40cb-45c3-872c-285143036da1', 'Ceremony', 426, 'Research Ceremony Options', 'Do you have space at your tent location for your ceremony? Remember to secure a rain back up tent so you do not getting wet during your vows.', 1,
    '12+ months', false, true, 'Wedding Icon 5.png',
    NULL, NULL, true, 'tented',
    true, NOW()
),
(
    '4c1475bf-baaf-4e49-82d5-194dc60e7df9', 'Ceremony', 426, 'Research Ceremony Options', 'Where do you picture saying "I Do"? Church, beach or your back yard? Knowing the vision helps guide venue selection.', 1,
    '12+ months', false, true, 'Wedding Icon 5.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '8d96f4e9-66ec-40ed-8444-4c3e67a453d2', 'Wedding Party', 425, 'Talk About Wedding Party Size', 'Are you having wedding parties? Start to think through who you would want standing next to you when you are saying "I Do" and how many people may be too many!', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '8fee0000-57a8-4eb7-a275-01391c0fdf75', 'Miscellaneous', 424, 'Decide Whether Kids Are Invited', 'This is a tough one, especially if you have many nieces and nephews! Better to decide now, let families know and post it to you''re wedding website.', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'e9f15a4d-4f17-45c6-8910-b66806cd206a', 'Legal & Admin', 423, 'Explore Wedding Insurance', 'Storms, cancellations, vendor issues - insurance can save your budget at an affordable cost. Be sure to read what the insurance covers because it will not cover everything!', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'd75c7c70-3479-42c0-95c7-09883c7124ba', 'Venue', 422, 'Considering a Backyard Tent?', 'It''s always best to bring the tent company with you, so they can accurately measure the space for you. Sizes can be deceiving', 1,
    '12+ months', false, true, '36.png',
    NULL, NULL, false, 'tented',
    true, NOW()
),
(
    '2a0a7561-90eb-4573-9832-35b45d032a18', 'Venue', 422, 'Start Scouting Venues', 'Make a list of your top 10. Yes, 10. You''ll be surprised how many get ruled out fast.', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '24fba5ad-2e7a-4d24-9c19-6bb8279ae2ad', 'Blank Fun Fact', 421, NULL, NULL, NULL,
    '12+ months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '492a821a-862d-4476-89bf-44d34c98ccb8', 'Guest Experience', 420, 'Discuss Overnight Guest Logistics', 'Do you need room blocks? Shuttle service? Airbnb clusters? Make sure you look into local travel advisors - they can be a big help with this large undertaking.', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '4de408ba-c30b-44cc-b69b-0e050a7a5620', 'Miscellaneous', 419, 'Consider Elderly Guests', 'Will you need to accommodate wheelchairs? Will your grandparents be a part of the processional or already be seated? Good to plan early.', NULL,
    '12+ months', false, true, 'Wedding Icon 99.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '0a2199e3-13cf-4213-bf57-fc653967df72', 'Beginning', 418, 'Determine Whether You Want a Multi-Day Experience', 'Do you want to make it a "wedding weekend"? Think about the night before and day after experiences - guests love to spend as much time with you as possible!', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'b55cf3b4-0058-4843-8975-0d9ad6f68589', 'Photography & Videography', 417, 'Decide on Photography Style', 'There are so many styles of photography - organic, documentary, bright. Do your research and see what you are drawn towards. Knowing this helps you find the right photographers.', 1,
    '12+ months', false, true, '42.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '55ece0b4-d15d-469c-a321-e5d5c0e7f505', 'Photography & Videography', 416, 'Start Researching Photographers', 'Start following local photographers. Look for consistency and storytelling, not just pretty portraits.', 1,
    '12+ months', false, true, 'Wedding Icon 58.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '187690c5-2579-4247-841c-4b192e5a40c5', 'Photography & Videography', 415, 'Start Researching Videographers', 'If video matters, do your research and book early. The best videographers are ALWAYS the first to book.', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'e29ec400-0ac8-4d8d-9e9a-92aa22fe29ad', 'Design', 414, 'Consider Your Theme or Color Palette', 'Your color palette guides EVERYTHING later - flowers, paper, linens, and more! Pro Tip from Heather - Use a color palette tool to help! It will even give you specific numbers to give to your stationary designer.', 1,
    '12+ months', false, false, NULL,
    'Heather''s Favorite', 'https://coolors.co/', false, NULL,
    true, NOW()
),
(
    '35d0117c-4bee-415a-ba8f-5e209341e652', 'Miscellaneous', 413, 'Talk with Your Partner About Wedding Day Traditions', 'There are so many wedding day traditions that you can opt in or out of. Talk through what you want to include and what you want to leave in the past! Bouquet toss, cake cut, first dance, etc.', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '364ca633-735d-48e2-a2b5-04fa9078ed13', 'Blank Fun Fact', 412, NULL, NULL, NULL,
    '12+ months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'fb28da85-528a-44d5-870d-d7b4df41670d', 'Ceremony', 411, 'Start Looking at Ceremony Readings', 'It is always nice to include a reading during your ceremony. It can be religious, your favorite song lyrics or a quote from a book. Consider something meaningful to the both of you and think through who would be best to read it at the ceremony.', NULL,
    '12+ months', false, true, '56.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'dbd2ac8d-4861-40c5-a8ce-c38a6dbf31bc', 'Catering & Bar', 410, 'Decide What Type of Food Experience You Want', 'Your guests will remember the food so be sure to think through your ideal food experience. Passed apps, food stations, plated meal, food truck - all options!', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '6150153e-baa5-42f0-9b38-1a44555fdd5a', 'Reception', 409, 'Cost of Linens and Rentals You Like Too High?', 'Consider some colored candles or bright menu cards to bring in color instead of high priced linens that are over the top expensive. This will save you tons.', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'ce271c0d-6439-42d2-b14a-7e0fdb2e885c', 'Budget', 408, 'Create a Preliminary Budget Breakdown', 'Allocate rough percentages to each category. This evolves, but the framework helps. Many think that a tented wedding will be less expensive, but many times it can be more!', 1,
    '12+ months', false, true, 'dollar_sign.png',
    NULL, NULL, true, 'tented',
    true, NOW()
),
(
    'cd53febc-94d3-43ef-b8c0-427a33724d9f', 'Budget', 408, 'Create a Preliminary Budget Breakdown', 'Allocate rough percentages to each category. This evolves, but the framework helps.', 1,
    '12+ months', false, true, 'dollar_sign.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '7b5f701a-beaf-4e14-9f18-07157abe712f', 'Legal & Admin', 407, 'Start Researching Local Marriage License Requirements', 'Do you need witnesses? A waiting period? A specific office to file in? **Destination weddings - be sure you know what the details are for your state or country!**', 1,
    '12+ months', false, true, 'Wedding Icon 99.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '877c366c-9a7d-4ca2-9eaa-33a386bb8f99', 'Ceremony', 406, 'If You Want a Friend to Officiate - Ask Now', 'People get nervous. Give them 373 days of warning. Pro Tip from Heather - It''s okay if they say no, it doesn''t mean that they don''t love you. They just panic during public speaking.', 1,
    '12+ months', false, true, '56.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '43d7e3ec-7162-4513-b45e-9ea6b039adc7', 'Blank Fun Fact', 405, NULL, NULL, NULL,
    '12+ months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '4ed4401e-69c4-46f6-bdb9-db1bf77a6dc1', 'Design', 404, 'Build a Mood Folder for Your Planner or Vendors', 'Screenshots, colors, textures, venues, florals, outfits - whatever inspires you. Photos help them to understand your vision.', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'f38664f9-4965-4fea-a8f8-496fc053b6da', 'Planning & Organization', 403, 'Break up Planning Into Monthly Tasks', 'These daily tips will help guide you, but your future self will thank you for not doing everything in one panic-filled weekend.', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '44bf0d62-83ff-4de8-a705-652aff695828', 'Beginning', 402, 'Write Out Your Non-Negotiables', 'Are there certain elements of your day that you have to include no matter what? Write those down as you plan and make your partner, parents and planner aware!', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'c3ed4f57-128b-4b07-a9a9-d628dd45f104', 'Miscellaneous', 401, 'Decide If You Want a Wedding Website', 'Most couples do. It becomes a huge timesaver later and less headaches from guests asking you so...many...questions.', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '151c450f-aadd-499a-9b93-c707fcad9c81', 'Planning & Organization', 400, 'Block Off Time for Planning Every Month', 'Like gym time, but emotionally harder and way more fun!', 1,
    '12+ months', false, true, '90.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '1484013e-eece-4e71-9e13-6f49626ac643', 'Planning & Organization', 399, 'Think About Weather Backup Plans', 'This is so important! Be sure you have back up plans for rain, wind, etc.', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '67525f8f-0a0a-4b7b-b71e-0f8f287cde10', 'Blank Fun Fact', 398, NULL, NULL, NULL,
    '12+ months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '468fab0b-4fdc-4e2d-a229-7a81b4e46ec0', 'Miscellaneous', 397, 'Visit a Wedding Show or Expo', 'Check you''re wedding venue or city for local wedding shows or expos - fun to go to even if you have all of your vendors already!', NULL,
    '12+ months', false, true, '175.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'cbca9558-ad11-4cbf-be89-0abc40a9dde2', 'budget', 396, 'Start a Savings Strategy', 'Automatic transfers. Hide money from yourself. Future-you will cry tears of joy.', NULL,
    '12+ months', false, true, 'dollar_sign.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '8afaa856-7bb6-4322-829a-81f6c000d71f', 'Miscellaneous', 395, 'Begin Your Registry', 'Your registry can include many different stores, honeymoon or new house funds and even local busineses. Registries are highly recommended as many guests are looking for the gift you want, not the gift they want for you!', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '085a5bf9-e3b1-47f1-8711-377b9203e0af', 'Catering & Bar', 394, 'Brainstorm Your Signature Cocktail', '“Marry Me Mojito”? “Something Blueberry Lemonade”? Pro Tip from Heather - Pick your favorite cocktail and name it after your fur baby!', NULL,
    '12+ months', false, true, 'wine glass with bow 4.png',
    'This Might Help!', 'https://amzn.to/3YNqd8U', true, NULL,
    true, NOW()
),
(
    'ec1c011d-6e55-4be6-a6eb-02c1fc2b8c0e', 'stationery & Paper Goods', 393, 'Start a Guest Address Spreadsheet', 'Future you will DEEPLY appreciate doing this early.', 1,
    '12+ months', false, true, 'Ring 2.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '451283ba-048d-41b2-945d-5cd5f2fca049', 'Blank Fun Fact', 392, NULL, NULL, NULL,
    '12+ months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '46388867-4ac0-4f9d-8d1b-f632395e48ea', 'Photography & Videography', 391, 'Consider Hiring a Content Creator', 'If you are big on social media and want images to use the following day, a content creator is a great addition to your vendor team. They will not replace your photographer or videographer, but capture the behind-the-scenes moments you never see.', NULL,
    '12+ months', false, true, '42.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '7b546371-2e81-48bf-9ef6-5be270925aec', 'Music & Entertainment', 390, 'Start Looking Into Entertainment Options', 'Entertainment is so important on you''re wedding day! Are you a DJ or band person? Do you envision strings or a harp for your ceremony? Or what about a live watercolor artist? Options are endless!', 1,
    '12+ months', false, true, '31.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'a57a986f-f7c4-4e95-8cdc-31935e46291b', 'Design', 389, 'Decide the Overall Vibe', 'What do you want your overall vibe to be - Elegant? Laid-back? Deciding this now will guide future choices.', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '493b7350-af8a-45f8-91c7-6de0337c6dc8', 'Miscellaneous', 388, 'Think About Pets at the Wedding', 'If your dog is the flower girl or you just want her there for photos, now’s the time to find a pet attendant service or designate someone to be in charge of her that day!', NULL,
    '12+ months', false, true, 'Dog.png',
    'Cutest Bandana!', 'https://amzn.to/4a1dEx0', false, NULL,
    true, NOW()
),
(
    '5f297d24-30b5-4d67-850e-58f7b57596e5', 'Wedding Party', 387, 'Choose Your Wedding Party (If You Want One)', 'Or choose no wedding party - which is totally a vibe too. If you do want a wedding party, choose wisely! These should the people you see by your side for the rest of your life, just like your partner!', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '79fcb3cb-edf3-407c-80f6-01a8821af2a2', 'Blank Fun Fact', 386, NULL, NULL, NULL,
    '12+ months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '05828ce0-10ba-43b8-b8ed-ff21e149ac26', 'Miscellaneous', 385, 'Look Into Room Blocks', 'Hotels book early. Especially in peak season. Ask your venue for the best options for guest accommodations and look into room blocks if possible. You do not need rooms for all of your guests - many will stay at local rental homes.', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'fb9d7350-2542-4b03-8274-7f0f2b68dbff', 'Florals & Decor', 384, 'Talk About Lighting', 'Bistro lights? Uplighting? Chandeliers? Lighting sets the entire mood. Pro Tip from Heather: Ask your entertainment what they provide for lighting. Some bands and DJs will provide dance floor or uplighting for an additional cost.', NULL,
    '12+ months', false, true, 'Wedding Icon 39.png',
    NULL, NULL, false, 'tented',
    true, NOW()
),
(
    '34c9fc37-4884-4ee5-9cd9-ae3257c1869d', 'Florals & Decor', 384, 'Talk About Lighting', 'Twinkle lights? Uplighting? Candle-heavy? Lighting sets the entire mood. Pro Tip from Heather! Ask your entertainment what they provide for lighting. Some bands and DJs will provide dance floor or uplighting for an additional cost.', NULL,
    '12+ months', false, true, 'Wedding Icon 39.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '6772e60e-d014-4251-9451-540949293725', 'Stationery & Paper Goods', 383, 'Start Looking at Save-The-Date Designs', 'Even if you won’t send them for a while, discovering your style helps.', 1,
    '12+ months', false, true, '52.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'd88f1206-8a71-4aa7-b817-4b0ab75e2660', 'Cake & Desserts', 382, 'Start Thinking About Desserts', 'Yum! Everyone loves a sweet treat at the end of the night, but there are many options to consider. From classic tiered wedding cakes to donut walls and large dessert stations. Our vote if we get one - Ice Cream Sundae bar of course!', NULL,
    '12+ months', false, true, '71.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'b3f61002-2481-4e23-9e02-99b64a9c1fb1', 'Blank Fun Fact', 381, NULL, NULL, NULL,
    '12+ months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '42108270-3e08-4cf0-b32d-6d13420831d4', 'budget', 380, 'Create a Shared Wedding Budget Tracker', 'This will help you to keep track of everything in one place, Google sheets works great for this (and it''s free!). You''ll thank us later.', 1,
    '12+ months', false, true, 'dollar_sign.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '23455dd4-6e3f-461d-a3a6-0161c52d0c4a', 'Vendors', 379, 'Start a Folder for Vendor Contracts', 'Digital folder, printed binder, or both. You''ll thank yourself later.', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'eed2f55d-c4a1-4fcc-8408-34675913ba91', 'Photography & Videography', 378, 'Make a List of Must-Have Photos', 'You don''t need a giant shot list, but note important family groupings, friend & college photos or sentimental moments.', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '7336eadb-8494-4dbe-b98f-4a834f674bc9', 'Catering & Bar', 377, 'Discuss Rehearsal Dinner Options', 'Your rehearsal dinner is meant to be an intimate dinner or gathering with those that have carried the two of you throughout your relationship and are standing with you as you get married. It can be intimate or you can skip it and throw a big welcome party for all guests!', NULL,
    '12+ months', false, true, 'food plate 2.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '041fab79-df64-4e4d-aee7-52c0bdad7f3f', 'Attire & Beauty', 376, 'Start Looking at Hair and Makeup Styles', 'Save photos to your pinterest board of styles that you love.', NULL,
    '12+ months', false, true, '86.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '71dc77a2-db99-4e33-8e46-1efa4cb9421d', 'Venue', 375, 'Finalize Your Venue Shortlist', 'Narrow it to 3–5 venues and start scheduling tours.', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'e81cd795-f6fc-476f-802b-c9e6ae9b2f48', 'Venue', 374, 'Take a Day Trip to Potential Locations', 'Nothing beats experiencing the space in person - including where the sun actually sets.', 1,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '9d57b3e4-51df-469b-ba57-96888d14f4f2', 'Venue', 373, 'Pay Attention to Seasonal Rates', 'Prices vary wildly depending on month and day of the week. Fridays and Sundays are often more budget-friendly.', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '07cd3032-6d8a-4eb8-a30e-34696540e97c', 'Blank Fun Fact', 372, NULL, NULL, NULL,
    '12+ months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '0ffc54d8-5e8f-4eb1-b9f2-e4c5660a29e1', 'Honeymoon', 371, 'Start Talking About a Honeymoon Budget', 'Before you book vendors, decide how much you’re allocating to the post-wedding bliss fund. It can be helpful to enlist the help of a travel planner, who can help to get travel freebies and perks.', NULL,
    '12+ months', false, true, 'Wedding Icon 63.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '1bcdf034-9b22-4ec8-9b98-1f59dc3cd8a5', 'Guest Experience', 370, 'Think Through Guest Comfort at Your Reception', 'With your tented wedding you will want to be sure your guests are comfortable! Consider shade or heating, bug spray and nice bathrooms. Guests love feeling considered, especially when being asked to spend an evening outside under a tent.', NULL,
    '12+ months', false, false, NULL,
    'Simple Pashminas', 'https://amzn.to/4a1oenD', true, 'tented',
    true, NOW()
),
(
    'e8e8bade-2e63-42a1-838a-39ce519ceca2', 'Guest Experience', 370, 'Think Through Guest Comfort at Your Reception', 'Consider air conditioning, heating, bug spray for any outdoor elements and more! Guests love feeling considered and comfortable!', NULL,
    '12+ months', false, false, NULL,
    'Simple Pashminas', 'https://amzn.to/4a1oenD', false, NULL,
    true, NOW()
),
(
    'c857b41a-c683-4f49-9192-c3f40155e655', 'Music & Entertainment', 369, 'Decide on Your Ceremony Music Style', 'Close your eyes and picture walking down the aisle - what do you hear? Strings? Acoustic guitar? Your favorite songs on a playlist? Price out your options before finalizing your decision!', NULL,
    '12+ months', false, true, 'Wedding Icon 87.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'd6d7b4c3-05fb-4f5c-ac16-8479319c666e', 'Venue', 368, 'Begin Thinking About Your Wedding Website Faqs', 'Shuttle info, dress code, location details, weather notes, etc. The more information you can share, the less questions you have to answer later.', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '43f5f69e-c8a5-462b-9c5f-954edcd1cf49', 'Planning & Organization', 367, 'Consider a Wedding Planning Membership or App', 'These tools can be great to keep you on track and all in one place!', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '246b6f26-e1b6-4925-b046-bde146652eb8', 'vendors', 366, 'Create a Running List of Questions for Vendors', 'Helps keep you organized for consultations and tours.', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'e25f368e-f1c9-44e9-bc6e-3129ecd7b4a8', 'vendors', 365, 'You Are Getting Married in One Year!', 'One year to go! It will be here before you know it!', NULL,
    '12+ months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '9f7787b1-535a-40d2-af71-40a66edeaf14', 'Miscellaneous', 364, 'Consider Fitness or Wellness Routines (If You Want To)', 'Not for aesthetics, but consider for sanity, stamina, and stress relief. Workouts, healthy choices, meditation - whatever may work for you!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '8277c5b0-e9e4-4e6e-9cb1-cbb0c696ecbe', 'Planning & Organization', 363, 'Plan a Couples’ Night to Celebrate the Start of Planning', 'You''re getting married! Celebrate the journey, not just the finish line.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'f8fe750c-562c-4d76-9aa7-c426f3a175cb', 'Photography & Videography', 362, 'Decide If You Want Engagement Photos', 'Great for save-the-dates, wedding website, and documenting this phase of life. Also a great way to get comfortable in front of the camera before wedding day.', NULL,
    '9-12 months', false, true, 'Wedding Icon 58.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '11e7d251-da49-4ff8-9610-7adb47ea072a', 'Reception', 361, 'Let''s Talk About Who''s Talking', 'Who’s speaking? When? At what event? Pro Tip from Jamie - keep the toasts at the wedding to 3 MAX! Use the events the night before for others who would like to speak.', NULL,
    '9-12 months', false, false, '146.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '05d19c50-f255-44ab-b6ae-19ab52dba10e', 'Blank Fun Fact', 360, NULL, NULL, NULL,
    '9-12 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'bde45739-e4d3-427f-aa31-cb18a1ed1959', 'ceremony', 359, 'Identify Any Cultural or Family Traditions You Want Included', 'If you have any religious or cultural elements you need to include in the ceremony or throughout the day, think these though early as they will definitely play a large role in your timeline!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '9cfcc956-93fd-4802-893c-a6d4100d69cd', 'Venue', 358, 'Begin Drafting a Wedding Website', 'You don''t have to publish it yet, but it should be published by the time your save the dates go out!', NULL,
    '9-12 months', false, false, NULL,
    'We Love Zola!', 'https://www.zola.com/wedding-planning/website?pkey=googlesem_desktop_brandexact_np_website&utm_source=google&utm_medium=cpc&utm_campaign=Brand%20(Exact)&orderkey=googlesem_desktop_brandexact_np_website&gzclid=CjwKCAiAybfLBhAjEiwAI0mBBkjHha0nbKwoNXU0_kQdHQhdoJyPb2RmzwVZNFzK0fmzQoYlx7KTpRoCC7IQAvD_BwE&gad_source=1&gad_campaignid=19702147897&gbraid=0AAAAACea2FT5lVe-vNlyotV3_HuupgM6E&gclid=CjwKCAiAybfLBhAjEiwAI0mBBkjHha0nbKwoNXU0_kQdHQhdoJyPb2RmzwVZNFzK0fmzQoYlx7KTpRoCC7IQAvD_BwE', true, NULL,
    true, NOW()
),
(
    'd8df86c2-7c11-4a7c-9d3f-19b9b306d369', 'Logistics & Day-Of', 357, 'Discuss Whether You Want a First Look', 'A first look is when the couple sees each other before the ceremony for a private moment with just the photo/video team. This allows for all formal photos to be taken before the ceremony, which can save a lot of time! Good to decide this early to help map out your timeline.', NULL,
    '9-12 months', false, true, '126.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'd9ea3371-caa6-4936-9196-59add46f392c', 'Florals & Decor', 356, 'Start Following Florists You Like and Set Up Consultations', 'Florals influence the whole aesthetic, so studying their style matters.', NULL,
    '9-12 months', false, true, '7.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '5ae968f6-fd90-4e13-825c-80c171747040', 'Attire & Beauty', 355, 'Book and Visit Bridal Salons for Dress Shopping', 'Always try on the styles you think you may not love. You never know until you try! We can''t wait to see the one you choose!', NULL,
    '9-12 months', false, true, 'Wedding Icon 15.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'aa805472-6aa3-4f07-9090-1f567a661845', 'Guest Experience', 354, 'Decide If You Want Welcome Bags', 'Fun but optional. Especially helpful for destination weddings. This is a great place to add in a weekend itenary or a list of your favorite local stops to make!', NULL,
    '9-12 months', false, true, '38.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '9722e257-deb3-40e0-a9f0-9fa717a87481', 'transportation', 353, 'Start Thinking About Transportation', 'Not all weddings need transportation, but if you do start thinking about it now. Do you need to move the wedding party or guests? Do guests need a way back to hotels? Price out all vehicles as some can be more expensive than others!', NULL,
    '9-12 months', false, true, '156.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '4f830349-0496-4d6e-b85d-b7405179521f', 'Blank Fun Fact', 352, NULL, NULL, NULL,
    '9-12 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'fcd661da-5f0c-4e78-8cf9-b34853dfb3fc', 'vendors', 351, 'Make a List of “Hard No” Vendors', 'Places you''ve had bad experiences or heard concerning things - cross them off early.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'a1970f0b-d0e6-4807-a602-bd5bbe7fdc62', 'budget', 350, 'Track Your Early Quotes', 'Prices change fast. Protect your budget by saving every initial quote you get.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '4429cc35-38af-4101-9268-d3285ebe2820', 'Guest Experience', 349, 'Ask Families About “Required” Guests', 'It’s better to know early than to get surprise names at invitation time.', NULL,
    '9-12 months', false, true, 'Wedding Icon 99.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'f7611951-838f-4099-b0d8-b8e6112f561a', 'Design', 348, 'Start to Look Into Design Elements', 'There are many design elements you can bring into your day from textured linens and colored glassware to chargers and flatware. Start exploring now, there are SO many choices!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '94378ed2-2c89-4cd0-bbda-b3b3cae2aa2f', 'florals & Decor', 347, 'Visit Local Florist Shops for Inspiration', 'What flowers are seasonal? What colors work year-round? Ask questions!', NULL,
    '9-12 months', false, true, '9.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '80f493e0-93a9-4c7d-9321-99764f88396b', 'vendors', 346, 'Look Into Local Rental Companies', 'Chairs, linens, tents, lighting - this becomes a big piece later. With a tented wedding, your rental order is going to be the backbone of you''re wedding day. And probably a big budget item. Pro Tip from Heather! It can be very expensive to rent the ever so popular ratan chargers though a rental company. Save yourself some of your budget and purchase them on your own. Sell them later on Facebook Marketplace.', NULL,
    '9-12 months', false, false, NULL,
    'Perfect Rattan Chargers', 'https://www.amazon.com/Bulrush-Placemats-Chargers-Farmhouse-Christmas/dp/B0FHQ2X697/ref=sr_1_5_sspa?crid=1BONCM0T47O1W&dib=eyJ2IjoiMSJ9.41IFvaNC-sb6IBapIZXGzwK5GMZB9BquXz6z3xbx38gdAiARo7Z43rpQ6t-ahFCv-ZMz_BPsJvMP07Era8bUBKNdxNJIXRJgVZ-TwIJ5Ew7Paeu90CX3JE8iQKmM79pMUaaA_omkSyQKe-9WR7USFxQSwFsiH3H6p0zQoWXwMl0APmFQhHmj630dVOn1a88GioyED7YNt-CkWN5tItERK-v6ONpl5DJ8iLGe5lUfaC4-xJgqW7DRiJctOCGHfztBb4asLPdBM-aDi3lhDImQgB6BeAZrF5xoxv2NlsHRfwU.iyZEm1c3TLeQmRXmUlgzHwXl-ClB2y6dQSZfiFZoG38&dib_tag=se&keywords=ratan%2Bcharger%2Bplates&qid=1768876411&sprefix=Ratan%2BCharg%2Caps%2C154&sr=8-5-spons&sp_csd=d2lkZ2V0TmFtZT1zcF9hdGY&th=1', false, 'tented',
    true, NOW()
),
(
    'fb89eb52-84ca-4700-b85e-e9af20dac0cd', 'vendors', 346, 'Look Into Local Rental Companies', 'Chairs, linens, lighting - this becomes a big piece later. Pro Tip from Heather! It can be very expensive to rent the ever so popular ratan chargers though a rental company. Save yourself some of your budget and purchase them on your own. Sell them later on Facebook Marketplace.', NULL,
    '9-12 months', false, false, NULL,
    'Perfect Rattan Chargers', 'https://www.amazon.com/Bulrush-Placemats-Chargers-Farmhouse-Christmas/dp/B0FHQ2X697/ref=sr_1_5_sspa?crid=1BONCM0T47O1W&dib=eyJ2IjoiMSJ9.41IFvaNC-sb6IBapIZXGzwK5GMZB9BquXz6z3xbx38gdAiARo7Z43rpQ6t-ahFCv-ZMz_BPsJvMP07Era8bUBKNdxNJIXRJgVZ-TwIJ5Ew7Paeu90CX3JE8iQKmM79pMUaaA_omkSyQKe-9WR7USFxQSwFsiH3H6p0zQoWXwMl0APmFQhHmj630dVOn1a88GioyED7YNt-CkWN5tItERK-v6ONpl5DJ8iLGe5lUfaC4-xJgqW7DRiJctOCGHfztBb4asLPdBM-aDi3lhDImQgB6BeAZrF5xoxv2NlsHRfwU.iyZEm1c3TLeQmRXmUlgzHwXl-ClB2y6dQSZfiFZoG38&dib_tag=se&keywords=ratan%2Bcharger%2Bplates&qid=1768876411&sprefix=Ratan%2BCharg%2Caps%2C154&sr=8-5-spons&sp_csd=d2lkZ2V0TmFtZT1zcF9hdGY&th=1', false, NULL,
    true, NOW()
),
(
    '81a1b3b3-21b0-4406-bdef-81b56e0e7c07', 'Blank Fun Fact', 345, NULL, NULL, NULL,
    '9-12 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '096b9cb1-c9ea-4c19-b2d4-808871c7d9e6', 'Ceremony', 344, 'Consider a “unplugged Ceremony”', 'Do you want guests present or taking photos? Depends on your vibe. Pro Tip from Heather - Nobody loves a photobomb of a guest hanging in the aisle with a phone to snap a pic. Especially your photographer. They will thank you.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '42dfb0d9-de20-4bbe-a760-f9029bbd6ccd', 'Ceremony', 343, 'Brainstorm Your Processional Order', 'Picture your ceremony and start thinking about who will be a part of the processional. Who walks when? Will you walk down the aisle with one parent or both? Solo? Good to start thinking through the flow early!', NULL,
    '9-12 months', false, true, '37.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '3c5305ba-b521-4fca-a5de-fb020e7b9817', 'vendors', 342, 'Stalk Local Vendors on Instagram', 'See whose personality, style, and energy you vibe with. Or if you have already booked vendors, follow local vendors for new ideas!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'a980479f-5e2e-430e-a43f-4a38bf6abbe5', 'Reception', 341, 'Think About the Flow of the Reception', 'Do you have a vision on how things will flow? Start thinking about cocktail hour, dinner, dancing and everything in between!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'bf337a43-7307-4455-9563-a450dd4a9376', 'vendors', 340, 'Discuss Boundaries with Vendors', 'Expected communication hours, preferred contact method, etc. Don''t text your vendors at 11PM.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '5b234a90-bd3f-4054-8b96-356357653a6e', 'budget', 339, 'Set up Automatic Savings', 'Weekly or monthly deposits into a wedding account make big payments less scary.', NULL,
    '9-12 months', false, true, 'dollar_sign.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '48f4ab84-765e-4457-9c5e-f8dcdabb3957', 'florals & Decor', 338, 'Floral Quote Too High?', 'You can ask your florist for revised quotes for flowers that look similar to the ones you love. Do you love Peonies but they are not in season on you''re wedding date? Garden roses look the same and cost 1/2 the price!', NULL,
    '9-12 months', false, true, '1.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '01017225-4235-495f-b6d6-3ba42bd6ced3', 'Attire & Beauty', 337, 'Think About the Style of Dresses You Want to Consider', 'With so many dresses to choose from, this can be overwhelming. Start to look at the different fit styles and consider what you are most interested in', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '92a325bb-a69f-4b46-9b28-e5a91078f0f6', 'Attire & Beauty', 336, 'Time to Order Your Dress', 'Dresses take months to order + alter. Make sure you ask when shopping how long each dress takes to be made and delivered!', NULL,
    '9-12 months', false, true, 'Wedding Icon 15.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '58679c66-88c2-4d04-bf38-f04d43b3ef4f', 'Legal & Admin', 335, 'Discuss Whether You Want Premarital Counseling', 'Relationship strengthening > planning stress. Some churches and religions require this, but if not, some couples still consider it!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '8562985b-00fb-492b-bd0d-d52b556090d2', 'Catering & Bar', 334, 'Think About Entertainment During Cocktail Hour', 'Your guests would love something to do other than eat and drink! Think about including lawn games a roaming oyster shucker or a mini putting green! So many options to keep your guests entertained!', NULL,
    '9-12 months', false, true, 'Wedding Icon 86.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'dff74807-c6f8-4ad3-8896-19d244a3cd0b', 'Miscellaneous', 333, 'Create a Private “do Not Forget” List', 'Start a note in your phone or a Google doc to track the little things you''ll forget in a year: vow books, cake-cutting set, emergency kit items.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '839b2c1c-783a-4ce5-8a20-1351cbe300d1', 'Blank Fun Fact', 332, NULL, NULL, NULL,
    '9-12 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '79420ed6-43f8-40e0-bfd0-17f0d624314e', 'Stationery & Paper Goods', 331, 'Start Considering Stationery Designers', 'Based on your style, consider stationary designers who fit your vibe - modern, watercolor, classic. And if you want custom work, start early!', NULL,
    '9-12 months', false, true, 'Wedding Icon 72.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '557374e6-1bd5-410e-8a69-7393a5099aa3', 'Attire & Beauty', 330, 'Think About Attire Changes', 'Who doesn''t love an outfit change?! Once you purchase the dress or tux, think through a second option to surprise your guests with during dancing! It''s always a good idea to have a back up too for those "just in case moments"', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '0fdcca52-8e4a-4cc4-8a24-b7c1cb771205', 'Guest Experience', 329, 'Brainstorm Guest Favors or Gifts', 'Locally sourced items are always crowd-pleasers. Make sure to ask your event coordinator if there are any restrictions around bringing these in.', NULL,
    '9-12 months', false, true, '189.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '11977b34-f358-4836-9599-c5be2340065a', 'Music & Entertainment', 328, 'Research Band Vs DJ Costs', 'There is always a debate as to which is better, but both can truly produce absolute magic - choose based on vibe and budget.', NULL,
    '9-12 months', false, true, 'Wedding Icon 84.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '1fb7760c-195b-4868-9f35-959f0b3ad629', 'Miscellaneous', 327, 'Decide If You Want to Have an Engagement Party', 'Are you excited to celebrate now? Kick off the fun with an engagement party...or skip it entirely! Be sure you discuss this with whomever the hosts would be!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '02600c59-be98-42b2-b0d3-04617ffd8c2b', 'Miscellaneous', 326, 'Begin Checking Local Events on Your Wedding Weekend', 'Festivals, sports events, or holidays can impact traffic, pricing, and availability.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '8368c50c-53d6-422b-9cec-1e46c60dcc8b', 'Logistics & Day-Of', 325, 'Discuss Wedding Weekend Events with Your Fiancé and Family', 'There are many additional events that can take place over you''re wedding weekend. Good to map out early as these locations can book up fast, especially on busy weekends!', NULL,
    '9-12 months', false, true, 'Wedding Icon 99.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'e1e7664d-b2f0-428c-a148-292fb867946b', 'Honeymoon', 324, 'Consider a "Minimoon" Before Your Honeymoon', 'Are you having a delayed honeymoon? You can still plan a mini get away right after the wedding to unwind and recap all things wedding day!', NULL,
    '9-12 months', false, true, '115.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '1fd70264-d3aa-4b07-8de5-b96cb442d9e1', 'Blank Fun Fact', 323, NULL, NULL, NULL,
    '9-12 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '1909bcd0-8444-4ad2-a8cb-6bc0fafc4f86', 'Planning & Organization', 322, 'Consider a Wedding Planner’s Options', 'If you have yet to book a planner, revisit and consider different levels of packages - Full service, partial planning, month of, are all great choices, it just depends on your needs.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '527aae81-4c1c-4023-a51c-af475d3c1bd4', 'Logistics & Day-Of', 321, 'Think About Group Activities for the Weekend', 'Are you having a "wedding weekend"? If so, start thinking about fun activities that you can plan or recommend to your guests - breweries, pickleball, beach day, skiing - what does you''re wedding destination have to offer?', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'f95bc83a-8799-4db4-875a-4fc9ca80d075', 'Guest Experience', 320, 'Map Out Where Guests Might Stay', 'Hotels, inns, rentals, and which towns make the most sense.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'c01f1708-26ab-4f9d-807d-085ec3b59259', 'Miscellaneous', 319, 'Decide on Engagement Announcement Timing', 'Engagement annoucements are not as formal as they used to be! But consider how you want the world to know! You can post on social media, submit to your local newspaper or keep it to yourself. Do what feels right to you.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '4ae626a4-b105-4673-9a89-82c78473f015', 'Reception', 318, 'Start Considering Your First Dance Song', 'Talk about ideas with your partner, may a playlist and see what fits your love story.', NULL,
    '9-12 months', false, true, '24.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '0146eee7-b781-4882-b84f-c6b5068beba5', 'Planning & Organization', 317, 'Create a Planning Calendar Reminder System', 'Use your app, Google Calendar, or reminders so tasks don''t sneak up on you.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'c99e212e-534b-4aa9-b6c2-d9af386a4c4d', 'Design', 316, 'Brainstorm Diy Projects', 'But be honest with yourself: Will you actually do them? Ask your venue coordinator or caterer if they will set these up for you. If not, skip now and save yourself future heartbreak.', NULL,
    '9-12 months', false, true, 'Wedding Icon 108.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '6d663eb4-9715-49ca-98e6-88889d878cda', 'Wedding Party', 315, 'Think About Wedding Party Proposals', 'Cards, gifts, or a simple heartfelt ask are all perfect. No need to overthink it!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '174ef7e2-76e6-449e-926b-041b01394f40', 'Blank Fun Fact', 314, NULL, NULL, NULL,
    '9-12 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'db090c59-8f06-48be-aa5a-3387f14810cd', 'Legal & Admin', 313, 'Start Browsing Ring Insurance Options', 'It’s usually inexpensive and provides peace of mind.', NULL,
    '9-12 months', false, true, 'Wedding Icon 99.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'a90ccdfc-3b38-4af0-a578-43062dc8c80b', 'Guest Experience', 312, 'Consider Guest Experience Flow', 'From parking to ceremony to cocktail hour to dancing - smooth transitions matter. Think about the different elevations of the yard - do you need to accommodate any guests who may be unsteady on their feet?', NULL,
    '9-12 months', false, true, 'Wedding Icon 108.png',
    NULL, NULL, true, 'tented',
    true, NOW()
),
(
    '74b4cdf5-9812-409e-91ce-18f98b7bc635', 'Guest Experience', 312, 'Consider Guest Experience Flow', 'From parking to ceremony to cocktail hour to dancing - smooth transitions matter.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '3e89003a-b2a2-4e42-a40e-2688d83b3b14', 'budget', 311, 'Begin Discussing Décor Budget', 'Rentals, florals, candles, linens - this adds up fast. Good to set expectations early.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '555035fc-9f9e-4479-9ced-fdd453f6ba05', 'Miscellaneous', 310, 'Ask Family About Heirloom Items', 'Are there any items that would be special to include in your day - jewelry, veil, brooches, cufflinks?', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '9b281c3c-aa52-4c8d-870f-62dafdb18d7c', 'Catering & Bar', 309, 'Explore Cocktail Hour Food Ideas', 'Raw bar, charcuterie board, sliders, gourmet popcorn - fun, interactive options thrive here.', NULL,
    '9-12 months', false, true, 'oyster plate 2.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '98d47771-56f8-4022-96b1-72211c82f7e8', 'Ceremony', 308, 'Collect Song Ideas for Ceremony', 'Wedding ceremonies call for a lot of specific music requests - start collecting your favorite song ideas early with a playlist on Spotify or Apple Music.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '1381b1d9-d0c5-41b4-b3d8-2434d80b5879', 'Attire & Beauty', 307, 'Think About Bridal Party Dress Color Palettes', 'What is your vision for you''re wedding party - guys and girls? There are so many options from miss-match to classic and pick your own. By thinking about it now and reviewing with you''re wedding party, this will make for easier decisions later.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '25cae8c1-5633-4aa8-8fe7-b09cca2be992', 'Blank Fun Fact', 306, NULL, NULL, NULL,
    '9-12 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '679eaba3-a6e0-43fa-b6da-b9127c4a3830', 'Attire & Beauty', 305, 'Consider Groom/partner Attire Options', 'Many option for the man in your life! It is nice to think through an option that would make him stand out amongst the others!', NULL,
    '9-12 months', false, true, '111.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'f20a621b-74d8-4508-a111-4d77491620c2', 'Miscellaneous', 304, 'Create Gift Tracking System for Showers and Wedding', 'A simple spreadsheet saves you from chaos later. If you are opening gifts at your shower, be sure to assign someone to track who gave what!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'b98263fc-9e78-4d38-a3ea-a47963822426', 'Photography & Videography', 303, 'Have a Real Conversation with Family About Photos', 'You may have family members that are thinking to use this day as a family photo shoot. Happens all the time. Make sure to have a conversation with them about keeping on track with your photo timeline. Each time a family member pulls your photo team away from you for a family photo opp slows down the day.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '32cdf61b-30ce-4547-a30e-7c42e95bb274', 'Stationery & Paper Goods', 302, 'Begin Browsing Invitations', 'Traditional, modern, minimal, vintage, illustrated - it is fun to start exploring ideas, but you have plenty of time!', NULL,
    '9-12 months', false, true, 'Wedding Icon 72.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'b58b7c6f-0fbd-4bbf-a8e8-540e05e3e8d8', 'Miscellaneous', 301, 'Think About Whether You Want a Wedding Painter', 'This could be a live painter for a special moment of the two of you or a custom watercolor artist who can paint your guests and send home the artwork as favors!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '3f998a8d-66fe-4ddb-892d-7b2c32291f73', 'Attire & Beauty', 300, 'Start Researching Hair and Makeup Artists', 'Check their portfolios & Instagram for real skin texture, not overly filtered photos.', NULL,
    '9-12 months', false, true, '86.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '6d92e0bf-63c0-4954-8d05-2f3ad2d41b4e', 'Ceremony', 299, 'Think About Your Vows', 'This is one of the most important things you will say to each other...ever. Talk through your vision - when are you sharing them with each other, how long should each be and do you wan to write your own or have your officiant help? All things to consider!', NULL,
    '9-12 months', false, true, 'Wedding Icon 9.png',
    'Romantic Vow Books', 'https://amzn.to/4bHytPj', false, NULL,
    true, NOW()
),
(
    'f38a4774-651c-490d-8765-34f11a96af7b', 'Catering & Bar', 298, 'Look Into Alcohol Options', 'Does your catering team provide the alcohol, or do you need to? Talk to your local liquor store to get a price quote early.', NULL,
    '9-12 months', false, true, 'Wedding Icon 62.png',
    NULL, NULL, false, 'tented',
    true, NOW()
),
(
    '9a5352fc-5a90-400f-b9ed-26cd73caf586', 'Catering & Bar', 298, 'Look Into Alcohol Options', 'Open bar, beer/wine only, specialty cocktails - decide early for budget planning.', NULL,
    '9-12 months', false, true, 'Wedding Icon 62.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'a539261e-42c9-4c2f-8265-7b3efb34b77b', 'Guest Experience', 297, 'Begin Working on Your Guest List More Seriously', 'Start grouping by A-list (must invite), B-list (nice to invite), and C-list (optional).', NULL,
    '9-12 months', false, true, 'Wedding Icon 99.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '376744bb-036c-46d1-b879-941e2c2519e8', 'ceremony', 296, 'Discuss Religious Elements', 'If you are having a religious ceremony, whether in the church or not, you will want to review readings, prayers, music and more. Be sure whatever you choose is approved by your church!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '0517433f-44d4-40d3-b65e-d6aa70a403a4', 'Miscellaneous', 295, 'Have a Signature Drink Taste Test Party!', 'Schedule a night with your besties and explore different signature drink ideas. Take time to think of clever names as well!', NULL,
    '9-12 months', false, true, '62.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'ac1cb928-2b8f-4fe8-85aa-22d618e71a5d', 'Attire & Beauty', 294, 'Look Into Suit/Dress Alteration Timelines', 'Alterers book up quickly - especially in peak season - and you won''t want to track someone down later on when you really need it!', NULL,
    '9-12 months', false, true, 'Wedding Icon 13.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'b4e530ab-60fa-4754-87d0-4c851aa1d0c2', 'Blank Fun Fact', 293, NULL, NULL, NULL,
    '9-12 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'eb48b7bb-4651-4321-b6e8-78f9c7e959d1', 'Guest Experience', 292, 'Start Thinking About Seating Layouts', 'Floor plans are fun and can be tricky! Think through your vision - do you see round tables or long banquet tables or a mix of both! All options! Ask your venue for samples of the floor plans that work best in their space.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'd0fb4960-c148-49b7-9722-4da1ba63b3a8', 'Venue', 291, 'Check on Other Events at Your Venue on Your Wedding Day', 'It is good to know ahead of time what else may be taking place at your venue that day. Other weddings or events? Do you have limitations on photo locations? When can your vendors access your venue?', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '47549ac2-d2fa-47eb-bf61-169803f2ad67', 'Venue', 290, 'Choose Your Tent Placement to Frame Views', 'Even turning your tent a few feet in one direction or another can make a big difference', NULL,
    '9-12 months', false, true, '36.png',
    NULL, NULL, false, 'tented',
    true, NOW()
),
(
    '1fc10215-1e0b-4207-a2a6-1ea96ea5c6b7', 'Music & Entertainment', 290, 'Make a Shortlist of DJs or Bands', 'Check live performance videos, ask friends who were married in the same city - the more referrals and live videos from weddings the better!', NULL,
    '9-12 months', false, true, '31.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '2614f4af-435f-4ed1-9b7d-5253587830ca', 'Honeymoon', 289, 'Check Your Passports and Ids', 'Don’t wait - applications and renewals take time for Passports and Real IDs', NULL,
    '9-12 months', false, true, '154.png',
    'Passport Covers', 'https://amzn.to/462roFj', false, NULL,
    true, NOW()
),
(
    '04a1891b-0118-46f2-9327-d08769e50d24', 'Florals & Decor', 288, 'Create a Mood Board for Florals', 'Use Pinterest or Canva to start pulling together ideas on your favorite bouquets, centerpieces, ceremony floral and more!', NULL,
    '9-12 months', false, true, '7.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'e2cae8a4-84ed-4896-9632-64ed1d8330d9', 'Stationery & Paper Goods', 287, 'Think About Day-Of Signage', 'Welcome signs, seating charts, table numbers, bar menus, bathroom baskets. With a tented wedding you may want to consider directional signage as well - parking, bathrooms, cocktail hour, etc.', NULL,
    '9-12 months', false, true, 'Wedding Icon 77.png',
    NULL, NULL, false, 'tented',
    true, NOW()
),
(
    '65f444e6-919f-4295-a062-c9744063bd68', 'Stationery & Paper Goods', 287, 'Think About Day-Of Signage', 'Welcome signs, seating charts, table numbers, bar menus, bathroom baskets, lots of options to add pretty paper!', NULL,
    '9-12 months', false, true, 'Wedding Icon 77.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '1ca055c1-f5e7-4e14-bf16-c7c79871c5e2', 'Planning & Organization', 286, 'Research “Month Of” Coordinators (If Not Using a Full Planner)', 'Some venues require a coordinator on-site., and even if they don''t having someone on site representin you and not the venue, will be a huge peace of mind', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '60807708-3116-4e9e-9827-08a8716617f0', 'budget', 285, 'Start a List of “Splurge Vs Save” Items', 'Splurge on: photography, food, florist? Save on: invitations, decor, dress alterations? Get aligned early.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'c15aad23-97d7-496a-86d3-5e0419f54afd', 'Miscellaneous', 284, 'Think About Surprise Moments', 'Surprising your guests is honestly, so much fun! Consider wow moments like a flyover banner or fireworks! Or can you arrive by boat or a cool car? What about custom merch everyone gets to take home? Think through what could be fun for your surprise element!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '47807d91-d514-46b4-84cc-b12d592574f2', 'Catering & Bar', 283, 'Do You Need to Rent Glasses for a Bar?', 'Talk to your catering team about quantities that you need to order. It''s more than you think. When renting glassware, your catering team will not wash them and will send them back dirty (totally normal!). Therefore, needing many glasses per person! Even if your venue provides glassware, you may wan to consider a special glass for your signature drink!', NULL,
    '9-12 months', false, true, '62.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'f83bc162-c139-4426-abe7-44684b905ceb', 'Attire & Beauty', 282, 'Consider a Shoe Strategy', 'Your footwear is SO important! Multiple pairs for the day of are a must, even if your last pair is your most comfortable pair of sneakers or flip flops!', NULL,
    '9-12 months', false, true, '109.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'b31b55c0-15ae-4d9a-a21c-4ddd856f8823', 'Blank Fun Fact', 281, NULL, NULL, NULL,
    '9-12 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '04a0ed5d-7375-4f6c-b3a4-c7f5f3e39284', 'stationery & Paper Goods', 280, 'Decide How You Want to Collect Rsvps', 'Online or classic mail in cards? Many couples are opting for online RSVPs as it is much easier for the guests to RSVP immediately and avoids any post office issues waiting for the cards to be mailed back. But it sure is fun getting physical mail!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '2aee1fb5-47af-455d-85f5-afdb4fa25ad2', 'transportation', 279, 'Start Looking Into Shuttle Companies', 'Help guests get from hotels to venue - especially in cities and towns where parking or ubers are tricky. Check with your property if there are any limit to numbers of cars allowed to park onsite', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, true, 'tented',
    true, NOW()
),
(
    '7bf2aff4-9437-496f-9ac3-f8d43f173c83', 'Transportation', 279, 'Start Looking Into Shuttle Companies', 'Help guests get from hotels to venue - especially in cities and towns where parking or ubers are tricky. Pro Tip from Heather! Giving guests an UBER code for a free ride can be easier than using a large transportation company!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '13961ac3-7da6-4838-b594-4c438c124eac', 'Guest Experience', 278, 'Think About Guest Dietary Needs', 'Your caterer or venue will take are of all of your guests with dietary needs, but be sure you ask them how they handle these requests so you can be prepared with answers when guests ask you!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'ffbe02af-858a-4e10-810c-d93265767912', 'Music & Entertainment', 277, 'Start a Shared Note for Song Must-Plays and Do-Not-Plays', 'This note comes in super handy when you are listing to music in the car or at the gym and hear a song you hate or love - add it to the list!', NULL,
    '9-12 months', false, true, 'Wedding Icon 89.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'c9be782c-6a4b-4d0f-8e78-533f408d395f', 'Venue', 276, 'Check Any Venue Noise Ordinances', 'Every town varies, so check in to be sure you know when music has to be shut down. Smaller towns have stricter rules in place, where cities you can usually party all night!', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'bac2f4b1-fc6f-4f2c-ba61-14a9063cb048', 'Blank Fun Fact', 275, NULL, NULL, NULL,
    '9-12 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'e3e007a4-7066-4c3f-bd00-5aee298dead6', 'Attire & Beauty', 274, 'Schedule Beauty Trials (Hair and Makeup)', 'Always recommended - you want zero surprises on the big day. Make sure you speak up at your trial of what you like and don''t like. This is what it''s for!', NULL,
    '9-12 months', false, true, '86.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'e83ac436-4123-4f25-beec-a0f698f77a4c', 'Venue', 273, 'Discuss Your Getting-Ready Locations', 'Where will you each get ready? How big does the space need to be? Natural light matters for photos.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'b28648fc-f0b9-42e9-90f8-4ec319ce1e83', 'Photography & Videography', 272, 'Meet Potential Photographers via Zoom or in Person', 'Chemistry matters. Even with your photographer', NULL,
    '9-12 months', false, true, '42.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '273ea48d-b118-420e-bb16-3a6f3761c8f3', 'Attire & Beauty', 271, 'Start Looking at Veil Styles (If Wearing One)', 'There are many styles of veils and it is best to try them on with you''re wedding dress to see what is a good fit. You may even find that your dress stands alone and no veil is needed! Pro Tip from Heather: If you are getting married inside or out - wind may be a factor here!', NULL,
    '9-12 months', false, true, '149.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '63186be0-885c-403c-b0d2-68b238985dec', 'Planning & Organization', 270, 'Plan a Wedding-Free Day', 'You deserve a break. No emails, no quotes, no Pinterest spirals.', NULL,
    '9-12 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'b2b0ab83-ab46-447c-95a4-06944fb5923d', 'Ceremony', 269, 'Consider the Size of Your Ceremony', 'Are you planning to invite your full guest list, or just a smaller VIP crew? Some couples even opt to have the real ceremony before wedding day!', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '81603e6b-4f56-4561-a522-8fe8d7030c54', 'Catering & Bar', 268, 'Choose Between Buffet, Plated, or Stations', 'Each creates a different guest experience (and significantly different timelines). Pro Tip from Heather! Make sure to talk to your caterer before deciding, as different style dinners may require different kitchen rental items. Those always drive the budget up!', NULL,
    '6-9 months', false, true, 'food plate 2.png',
    NULL, NULL, true, 'tented',
    true, NOW()
),
(
    '4514a151-c24b-4ca0-a093-749c3104831b', 'Catering & Bar', 268, 'Choose Between Buffet, Plated, or Stations', 'Each creates a different guest experience (and significantly different timelines).', NULL,
    '6-9 months', false, true, 'food plate 2.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '39f608a5-d8ad-4bd6-838e-9e1f48e3fc76', 'Blank Fun Fact', 267, NULL, NULL, NULL,
    '6-9 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '527f6584-d9a5-4d59-9325-cee443670237', 'Venue', 266, 'Begin Brainstorming Rehearsal Dinner/Welcome Party Venues', 'Many venues book up quickly so be sure to explore your options - restaurant, brewery, backyard - and lock it in!', NULL,
    '6-9 months', false, true, '38.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '65dc49bd-5c0d-45d9-a5b3-caf817e2cae1', 'Stationery & Paper Goods', 265, 'Explore DIY Invitations vs Hiring a Designer', 'Factor in time, skill, and stress levels before committing to DIY.', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '5b065ad3-cad1-4d9d-a7f1-f26c27528f0c', 'Ceremony', 264, 'Consider the Design of Your Ceremony', 'With an outdoor ceremony, you most likely have some space for some more fun designs, like a circle or semicircle shape. Pro Tip from Jamie - Definitely rent two sets of chairs for your ceremony and reception, especially if your guest count is over 50 ppl!', NULL,
    '6-9 months', false, true, '48.png',
    NULL, NULL, true, 'tented',
    true, NOW()
),
(
    'b85c5961-8780-4164-8806-8b90a34b0f0f', 'Ceremony', 264, 'Consider the Design of Your Ceremony', 'Reconfirm the ceremony space with your venue and review what they offer for chairs and layout. Defer to them for best layouts.', NULL,
    '6-9 months', false, true, '48.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '3d6438f9-74f0-4741-a7f9-3b42e04f7f9a', 'Attire & Beauty', 263, 'Test Hair Products You May Use Day-Of', 'Ask your hairdresser what products they may recommend for your hair type and test them out early - you won''t want to experiment last minute!', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '2de60be3-cbda-41cb-be38-ab73df96ab3e', 'Miscellaneous', 262, 'Begin Asking Parents About Their “Must Haves”', 'Especially if your parents are contributing to the budget, it is nice to ask them about anything they would really like to have at the wedding. A special song? A cultural tradition?', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'e25690e2-d1c6-4e46-b002-1d1a593acae5', 'Blank Fun Fact', 261, NULL, NULL, NULL,
    '6-9 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '83307c90-8921-4ae5-9266-97f72920b58f', 'budget', 260, 'Discuss Gratuities for Vendors', 'This helps you budget realistically. Make sure to ask your vendors if gratuity is included or expected.', NULL,
    '6-9 months', false, true, 'dollar_sign.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '41718034-7b88-4cc1-9d81-abe565f7ec17', 'Honeymoon', 259, 'Start to Brainstorm Locations for Your Honeymoon', 'Choose a locations that feels like you. Not just where instagram tells you to go.', NULL,
    '6-9 months', false, true, '115.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '74edd40a-2d85-4169-b269-eff5f74b87c1', 'Catering', 258, 'Consider Passing Drinks As Guests Enter the Reception', 'No one likes a line at the bar, be sure to consider 1-3 passed drinks as guests arrive to cocktail hour to take the initial hit off the bar. Your guests will thank you!', NULL,
    '6-9 months', false, true, '62.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '0ae46292-602a-4795-91fd-b806a7c8e3bf', 'transportation', 257, 'Does Your Venue Have Transportation Restrictions?', 'Consider giving your guests uber codes for a discounted ride. It can be easier than trying to get school busses into tight locations.', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '142d6706-85e0-48b2-9be9-f6ff65ff62d0', 'Attire & Beauty', 256, 'Start Thinking About Wedding Attire Shopping Timeline', 'Dresses take months to order and alter. Suits take tailoring too. Consider who you want to bring with you. Keep in mind - the more friends you bring, the more opinions you get! (which you may not always want!)', NULL,
    '6-9 months', false, true, 'shopping bag.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'd3896d32-fa54-47ca-b664-3bd107581621', 'Guest Experience', 255, 'Set Guest Expectations Early', 'Share ceremony length, outdoor elements or walking distances on your website.', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'b5a9b340-da9d-402e-b842-942ba8e74345', 'Planning & Organization', 254, 'Review Sample Timelines Online', 'This helps you imagine you''re wedding day flow. Pro Tip from Jamie - ask for past timelines from your venue manager or planner so you can get insight as to how past events looked at your venue', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '0e962754-4be4-4406-bf74-e5d9cdec4595', 'florals & Decor', 253, 'Look Into Specialty Linens', 'Textured or patterned linens and napkins can make a big impact. Make sure you talk to your venue about what is included and be sure you see photos in case you don''t love it!', NULL,
    '6-9 months', false, true, '57.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '9886ba31-bde2-430b-99cb-e20c3db2d8d7', 'Blank Fun Fact', 252, NULL, NULL, NULL,
    '6-9 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '0d87c6fe-790a-457b-a67d-6d9f4cbb0c8b', 'Music & Entertainment', 251, 'Keep Testing Playlists for Ceremony and Reception', 'Spotify adventures and dance parties with friends count as research!', NULL,
    '6-9 months', false, true, 'Wedding Icon 37.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '88c48b47-e004-49cf-b3e8-2b20fd10e881', 'florals & Decor', 250, 'Decide About Your Bouquet Style', 'Your bouquet is a very special element of your day. Find inspiration you can share with your florist. Do you like loose and organic or structured classic? What color florals do you want popping against your dress?', NULL,
    '6-9 months', false, true, '7.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '1887b2ea-b87b-40af-a583-f53c28877fe7', 'Miscellaneous', 249, 'Consider Family Dynamics Early', 'Families can be fun! Talk out all dynamics now so that you can manage seating arrangements and avoid any drama later!', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '7d466680-eeca-4508-944a-52b992f313f5', 'catering & Bar', 248, 'Start Thinking About a Signature Mocktail', 'Mocktails are having a moment for drinkers and non-drinkers - so it is a fun menu addition for those that don''t drink or want to take a break!', NULL,
    '6-9 months', false, true, 'wine glass with bow 4.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'd5070269-5993-46fc-ac62-897b11d5ab90', 'florals & Decor', 247, 'Decide on Bridal Party Bouquet Style', 'Consider different bunches of the same bloom for each attendant or a smaller version of your bouquet - so many options! Ask your florist what they may recommend based on what they are wearing.', NULL,
    '6-9 months', false, true, '9.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'f5808133-9dd4-463c-ba50-b38904d39da6', 'Cake & Desserts', 246, 'Think About Cake Flavors', 'Ask your cake baker what options they offer, but don''t be afraid to ask for custom flavors as well! If you love mocha oreo, many will accommodate your request!', NULL,
    '6-9 months', false, true, '66.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '91bfe551-8329-4938-a91b-3c352f0eda04', 'Miscellaneous', 245, 'Consider Sharing Your Story on Wedding Day', 'Guests love learning more about your story - think about fun facts on cocktail napkins, photos of the two of you throughout your relationship, your favorite drinks, etc.', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '06af7002-055e-4b78-a62c-88ea49b420a8', 'Blank Fun Fact', 244, NULL, NULL, NULL,
    '6-9 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'fb1cb806-bb0b-4bb3-92aa-31f516eaa11f', 'Logistics & Day-Of', 243, 'Think About a Private Vow Exchange', 'Many couples are sharing private vows before the wedding and standard vows at the wedding - which do you prefer?', NULL,
    '6-9 months', false, true, '64.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '8645e8fa-e382-42f1-ad44-7a498c0fc464', 'Attire & Beauty', 242, 'Brainstorm Rehearsal Dinner Dress/Outfit Options', 'Because you absolutely need a second outfit.', NULL,
    '6-9 months', false, true, '109.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '2ef743e3-2e1e-4e0e-8da9-9bfcee46a864', 'Transportation', 241, 'Begin Planning Your After-Party', 'Will you want to keep the party going after the reception ends? Be sure to think through convenient locations, how your guests are getting there and if there will be more food or music. Make it unique!', NULL,
    '6-9 months', false, true, 'Wedding Icon 92.png',
    'Best Party Props!', 'https://amzn.to/45nQnCW', false, NULL,
    true, NOW()
),
(
    'bf410210-3218-4d46-90e7-f28c7eecad4d', 'Photography & Videography', 240, 'Decide Whether You Want Videography Extras', 'Drone footage? Raw footage? Teasers? Full documentary cut? Social Media trailer? There are so many add ons to videography, make sure to think about the ones that you will watch often in the future to help decide what''s important to you.', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'e439667e-367b-4e71-b350-e8e3b08602c2', 'Miscellaneous', 239, 'Look Into Wedding Day Perfume or Cologne', 'If you pick a new scent for the day, this will help allude to memories of your day. It is a cool sensory moment to take with you!', NULL,
    '6-9 months', false, true, '89.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'ff5dd5cf-47d8-493a-b7f3-2ba8ce7922f2', 'Guest Experience', 238, 'Consider Where You Are Placing Guests on Your Floor Plan', 'Think about where people are going to sit strategically. You don''t want to put your Grandparents next to a loud band speaker, and you also don''t want them to have to walk far to the restroom. Save the loud music seats for your friends that you know will be on the dance floor all night.', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '1744fcfa-fac6-4906-8555-ccfa36b50e7b', 'Attire & Beauty', 237, 'Start Thinking About Hairstyle Trials', 'Updo? Waves? Sleek bun? Half-up? Think about how this will fit in with the dress style you are considering. Make sure you consider outdoor elements, if you plan to dance the night away under the stars outside!', NULL,
    '6-9 months', false, true, '148.png',
    NULL, NULL, true, 'tented',
    true, NOW()
),
(
    'aa6c881d-b92b-488f-a577-0aecd928812d', 'Attire & Beauty', 237, 'Start Thinking About Hairstyle Trials', 'Updo? Waves? Sleek bun? Half-up? Think about how this will fit in with the dress style you are considering. Always consider outdoor elements, wind can quickly be the enemy of soft flowing curls.', NULL,
    '6-9 months', false, true, '148.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '93df1551-ad7a-4f0f-880e-ab5a631efa4c', 'Attire & Beauty', 236, 'Consider Renting Vs. Buying Attire', 'Renting suits is common; dress rentals are growing too - especially for a welcome party or after party.', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '088d9bda-3962-4f32-ad78-b003b8a44611', 'Guest Experience', 235, 'Think About Ceremony Seating', 'Traditional rows, circle ceremony, curved seating - unique layouts change the whole feel.', NULL,
    '6-9 months', false, true, 'Wedding Icon 108.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '1f1faef1-08bf-4d0e-81e3-ff85f0c91155', 'transportation', 234, 'Discuss Transportation for the Wedding Party', 'Will the wedding party need transportation to and from the venue? Consider a trolley, party bus or sprinter vans.', NULL,
    '6-9 months', false, true, 'trolley.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'bd26f762-4fa7-476f-bce7-f872ad471f73', 'Blank Fun Fact', 233, NULL, NULL, NULL,
    '6-9 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'bd50ea1c-d635-47ff-bdf4-3c3f80dfde94', 'Guest Experience', 232, 'Think About Guest Shuttles', 'Especially helpful if parking is limited or if alcohol is served. There are many different types of shuttles like buses, trolleys, or sprinter vans. Make sure to consider the different sizes that can easily fit at your venue and the amount of guests they can hold.', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'b3fdb107-ab6d-4ef3-90d5-b0cbae3dcee2', 'Honeymoon', 231, 'Discuss Honeymoon Timing', 'Right after the wedding? Delayed honeymoon? Mini-moon first? It''s okay to take some time before you travel. It''s nice to have something to look forward to a few weeks or even months after the wedding.', NULL,
    '6-9 months', false, true, 'Wedding Icon 63.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '9a8d3419-0366-4adb-9c10-3b07eff94b8b', 'Miscellaneous', 230, 'Create a "Things to Buy" List', 'Start thinking through things you may need to buy - nice hangers, cocktail napkins, after party props, etc. And then determine best time to purchase - keep in mind times of year like Cyber Monday!', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '29bc7237-38f5-4622-a84e-781808fd66c8', 'Florals & Decor', 229, 'Explore Centerpiece Styles', 'Tall? Low? Mix of both? Statement pieces vs. simple greenery. If your considering candlelight, you may want to think about battery operated. Wind and candle flames don''t mix well.', NULL,
    '6-9 months', false, true, 'Flower Vase 4.png',
    NULL, NULL, true, 'tented',
    true, NOW()
),
(
    '67126ad2-123e-4b45-a965-ea85011c8aed', 'Florals & Decor', 229, 'Explore Centerpiece Styles', 'Tall? Low? Mix of both? Statement pieces vs. simple greenery. Think about including different color candles to add some layers to your design. They can offer a big wow factor without a large budget impact.', NULL,
    '6-9 months', false, true, 'Flower Vase 4.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'a68c1ad8-838e-421b-9596-02217bdd5e23', 'Ceremony', 228, 'Think Through Ceremony Entrance Songs', 'Separate songs or one shared? Instrumental or vocal? Consider matching the tone of your ceremony. Would you like it to be more formal, or an upbeat party vibe? Choose something timeless for Grandparents, it often means a lot to them.', NULL,
    '6-9 months', false, true, '37.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '36d98d22-78ed-4c4c-85c4-2823d5c25c39', 'Ceremony', 227, 'Discuss Ceremony Length', '10 minutes? 20 minutes? Full service? Keep it true to you. Make sure you coordinate with the start time of your cocktail hour.', NULL,
    '6-9 months', false, true, '56.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '2834d53a-a300-4ed0-97c5-fb41c3e450b6', 'Attire & Beauty', 226, 'Begin Testing Out Wedding Shoes', 'Wedding tents are typically on grassy areas. Consider shoes that will lend well to this type of surface. Block heels vs. spike heels are the way to go here.', NULL,
    '6-9 months', false, false, NULL,
    'Save Your Heels', 'https://amzn.to/49AFvTe', true, 'tented',
    true, NOW()
),
(
    'b9b86181-eeaf-4e8b-8fd2-03568a955c1f', 'Attire & Beauty', 226, 'Begin Testing Out Wedding Shoes', 'Wear them around the house to see what hurts (everything). Pro Tip from Heather - Put them in the freezer for a few hours first - this can help them stretch if they are too tight!', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'a715b0a5-4b13-4c4c-b063-75566161c7bc', 'Florals & Decor', 225, 'Consider Renting or Buying Decor Instead of Diy', 'DIY is cheaper until it isn’t. Be realistic with time and stress levels. Most florists will give the option to rent vases and candles for you!', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'ff8ff18d-d397-4dd6-a1a0-5f5270772578', 'Attire & Beauty', 224, 'Begin Browsing Tux/Suit Boutiques', 'Local shops often have great custom options, but also ask around to see if any friends or family had great experiences they can recommend.', NULL,
    '6-9 months', false, true, '120.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'f29b2c15-9efa-4e5d-8d54-0f0d0581b57a', 'Blank Fun Fact', 223, NULL, NULL, NULL,
    '6-9 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '75f93910-f9df-4a33-9e15-d3a3ecb10b4a', 'Photography & Videography', 222, 'Decide If You Would Like to Display Any Photos at the Wedding', 'Parents’ and Grandparents'' wedding photos, engagement photos, childhood photos? Always a nostalgic moment!', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '81a5102c-1ffb-498d-b4c3-adecc54f2672', 'Cake & Desserts', 221, 'Explore Dessert Table Options', 'Cookies, brownies, cannolis, macarons, s''mores bar - crowd pleasers galore. Dessert tables can be a fun addition for your guests - there is something for everyone.', NULL,
    '6-9 months', false, true, '70.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'f7615369-78a5-457e-a3d8-85567aabc72e', 'catering & Bar', 220, 'Start Considering a Late-Night Snack', 'Pizza, fries, mini burgers… drunk-hungry guests will love you. Ask your catering team if you can plan to offer these for 75% of your guests. This will help save on your budget and a few guests may have departed by that time.', NULL,
    '6-9 months', false, true, '69.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '40dc75f8-4d8a-4edd-9ad1-c1974738d610', 'Logistics & Day-Of', 219, 'Talk About Staged Exit Ideas', 'Sparklers? Bubbles? Glow sticks? Cold sparks? Or no exit at all. If you are considering sparklers or cold sparks, be sure your venue allows for them!', NULL,
    '6-9 months', false, true, '153.png',
    'LED Ribbon Wands', 'https://amzn.to/4qwqWYk', false, NULL,
    true, NOW()
),
(
    '23a3abfc-513d-45b0-b16b-98d4fef034c7', 'Attire & Beauty', 218, 'Begin Planning Your Budget for Beauty Services', 'Hair, makeup, tan, nails, waxing, trial sessions - it adds up. Consider if you are paying for all services for your bridal party, or they will be covering this cost. Make sure you give them plenty of notice of the expnse so they can prepare accordingly.', NULL,
    '6-9 months', false, true, '89.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '40a2910b-8934-458e-a5be-784d9359973f', 'Photography & Videography', 217, 'Research Photography Add-Ons', 'Second photographer? Film add-on? Extra hours? Drone? These change the quote quickly. Make sure your hours that you have scheduled with them will get you from hair and makeup touchups, untill your dance floor opens so you don''t miss a moment. This is usually 8-10 hours.', NULL,
    '6-9 months', false, true, '42.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '879e00ba-533a-41ce-b308-6a50a8978e7c', 'music & Entertainment', 216, 'Decide If You Want to Take Dance Lessons', 'Not sure how you will survive your first dance? Think about taking dance lessons - choreography is not necessary, but making sure you have a dip or spin makes for a great applause!', NULL,
    '6-9 months', false, true, 'Wedding Icon 89.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'c3d64289-59d1-471a-ac58-c45796eb6159', 'Catering & Bar', 215, 'Look Into Menus and Food Tastings', 'Most caterers or venues will reach out to you when they are scheduling tastings, but they tend to book up fast. Be sure to get on the schedule!', NULL,
    '6-9 months', false, true, 'food plate 2.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'dc9544c8-0351-46e3-b5af-d7260ad1ad14', 'Planning & Organization', 214, 'Start Thinking About the Ceremony Processional', 'Who goes where? Who walks when? Where do they sit? How long does it take to get down the aisle? Take notes and map it out, will be so helpful at your ceremony rehearsal. Pro Tip from Heather! If you have a large bridal party, it might be helpful to put name tags on seats to help remind them where to sit. Your venue team can set these up for you!', NULL,
    '6-9 months', false, true, '37.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '9f51f98c-9b23-4f38-95ba-6e89241435c9', 'Logistics & Day-Of', 213, 'Kids Invited? Think About a Kids’ Table or Activity Bags', 'If children are attending, keep them entertained and parents happy by providing things for the kids to do - coloring books, glow sticks, bubbles?', NULL,
    '6-9 months', false, false, NULL,
    'Kids Doodle Board', 'https://amzn.to/4pLYjFa', false, NULL,
    true, NOW()
),
(
    '161c86e0-63d9-4e54-943a-46ff1f03c3c2', 'Blank Fun Fact', 212, NULL, NULL, NULL,
    '6-9 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '81299484-22ba-4515-bfed-db923f8281d3', 'Logistics & Day-Of', 211, 'Decide Whether You Want a Bouquet Toss', 'When considering the bouquet toss at you''re wedding, think through how many single people will be attending, because if there are not enough, you can skip it entirely! Or get creative and hand your bouquet to the couple who has been married the longest or your grandmother.', NULL,
    '6-9 months', false, true, '2.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '3cae0a8c-e27d-4e99-b47d-6dc67f15b926', 'Guest Experience', 210, 'Consider Adding a Welcome Toast', 'At the rehearsal dinner and/or welcome party. Sets a warm tone for the weekend. You can also include a welcome toast at the wedding by the hosts, which is a nice way to kick off the evening.', NULL,
    '6-9 months', false, true, '144.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '86140f42-e61b-498d-8331-e8ae3cf673fc', 'Catering & Bar', 209, 'Talk About Morning-Of Food', 'Fruit platters? Bagels? Breakfast burritos? Don’t let anyone pass out from low blood sugar. (or to many early mimosas!) It''s helpful to have a bag of snacks that are easy to eat incase you get hungry or nerves start to kick up before your ceremony. Hard candy can help if you need a bit of sugar before walking down the aisle.', NULL,
    '6-9 months', false, true, 'food tray 1.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'b9803005-cd1d-4b96-b9bb-2e56f3d24f6f', 'Miscellaneous', 208, 'Date Night!', 'Take a break from planning today and have a date night! Or plan one for next week! Days of from planning make for a healthy planning process!', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '118bb476-0ee7-48d6-957e-99fd6f719fc8', 'Miscellaneous', 207, 'Look Into Spa or Wellness Options', 'Massages? Facials? You can plan these leading up to the wedding (who doesn''t want a regular spa appointment?!) and/or plan for the week of the wedding. Just be sure you are not going to a new facialist the week of you''re wedding!', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'fca63c4a-1af7-4edf-9f1a-d2a13f685c40', 'Ceremony', 206, 'Decide on a Ceremony Recessional Song', 'Upbeat? Romantic? Absolute banger? Your choice sets the tone for cocktail hour. Pro Tip from Heather: choose a song that is instantly recognizable in the first 5–10 seconds. Her Favorite? “Can’t Stop the Feeling!” from Justin Timberlake obviously!', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '334988c4-c0d1-4354-8ddf-da9709ece421', 'stationery & Paper Goods', 205, 'Consider Hiring a Calligrapher', 'For envelopes, signage, or special details that elevate the look. Necessary, not really!', NULL,
    '6-9 months', false, true, 'Wedding Icon 78.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'ce51dab3-d7c8-4361-817c-3d0f8a564b6b', 'Guest Experience', 204, 'Think About Your Guestbook Style', 'Polaroid book? Audio guestbook? Advice cards? Jenga pieces? So many fun options. Make sure to check out Heather''s favorite, Voast! it''s a fun interactive guest book that you can move with you throught the wedding day. Personalized questions about you for your guests are always funny to watch back!', NULL,
    '6-9 months', false, true, '44.png',
    'Voast', 'https://raiseavoast.com/?utm_term=video%20guest%20book%20wedding&gad_source=1&gbraid=0AAAAAogFUU7R__TgKwd5HRHiJfFvxDTA3', false, NULL,
    true, NOW()
),
(
    'f567dfab-1844-4de2-b8cf-be9cfcc80974', 'Planning & Organization', 203, 'Factor in Sunset Photos', 'Golden hour timing = magic. Based on you''re wedding venue, the sun will set at XXXX which means you want to aim for 30 minutes before for the best photos!', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '7bd06369-701b-4cbe-a6b0-c733497fc4b1', 'Blank Fun Fact', 202, NULL, NULL, NULL,
    '6-9 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'ff2a9601-ee3c-4483-a7fc-953017eeaef6', 'Photography & Videography', 201, 'Decide If You Want Pet-Inclusive Photos', 'Plan for a handler early - pets love weddings but hate logistics and you don''t want to be dealing with your pet while you are all dressed up!', NULL,
    '6-9 months', false, true, 'Dog.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '8e69f881-ac66-4781-aec4-3c84382df94c', 'Photography & Videography', 200, 'Create a Must-Take Family Photo List', 'It is good to get ahead of this so that you can avoid any chaos or drama day of. Try not to overthink it!', NULL,
    '6-9 months', false, true, 'Wedding Icon 58.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'c3a41f6f-e0d2-4f29-8b2a-76257a7b6cdd', 'Stationery & Paper Goods', 199, 'Think About Table Number Styles', 'Paper? Acrylic? Custom? The same person who designs your invitations can do this for you too, so they are all cohesive. Make sure the size makes it easy for the guests to see as they are walking into the dining room. Don''t forget to remind your catering team to face them towards the entrance doors, making it as easy as possible for guests to see.', NULL,
    '6-9 months', false, true, 'Wedding Icon 73.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '5b82dee5-6dd3-4ec2-8a84-a4382ecf584e', 'Guest Experience', 198, 'Decide If You Want Assigned Seating', 'Escort cards? Seating chart? Free-for-all? Assigned seating reduces stress for guests and especially your catering team. They will truly love you for assigning seats. If you take it one step further and assign each seat at each table, your catering team will love you forever. This makes it easy for them to know exactly where each specific entree should be delivered.', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'a8603e76-e2bb-4f27-9772-a692b9870a32', 'Attire & Beauty', 197, 'Begin Curating Getting-Ready Outfits', 'Robes, PJs, matching sets - or comfy basics. Your choice. It''s also okay if you don''t want to match - do what you feel comfortable with and keep in mind that it''s just for a few photos!', NULL,
    '6-9 months', false, true, 'Bow 3.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '300efb46-6717-4a17-8bd8-31abf2c3a115', 'Guest Experience', 196, 'Decide Where You Want to Sit', 'Head Table or Sweetheart Table - Each changes the event flow and photos. Make sure your venue offers the right size table you need as you may need to rent this in!', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '739963a7-9289-4185-acf1-fb388752ab54', 'Miscellaneous', 195, 'Start Ring Shopping!', 'Decide where you want to purchase your rings. A good place to start is the same jeweler that made the engagement ring. Don''t forget a cute box for your photos, check out this one that''s our favorite!', NULL,
    '6-9 months', false, true, '94.png',
    'Best Ring Box', 'https://amzn.to/4aSFwo1', true, NULL,
    true, NOW()
),
(
    '8dd46e51-93ab-456e-8937-292aa59fcb72', 'florals & Decor', 194, 'Consider an Heirloom Detail in Your Bouquet or Boutonniere', 'Locket, charm, handkerchief, ribbon - meaningful touches. Pro Tip from Jamie - Make sure you designate a plan for this after the ceremony - keep it safe!', NULL,
    '6-9 months', false, true, '9.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '8e113aca-c810-4b85-b427-501ff165d0cd', 'Blank Fun Fact', 193, NULL, NULL, NULL,
    '6-9 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '87e3d059-6bf6-4830-abe3-10736a424ff3', 'Florals & Decor', 192, 'Research Ceremony Decor Options', 'There are many elements to consider for your ceremony - think through decor and guest elements. From florals to a petal toss and ceremony programs, make sure you include what is important to you. Pro Tip from Jamie - We do not suggest using an aisle runner as they tend to bunch and become a tripping hazzard!', NULL,
    '6-9 months', false, true, 'Arches3.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '106f975c-d3a5-49a0-bc89-abdbd690e489', 'Attire & Beauty', 191, 'Bustling Your Dress?', 'Make sure you talk to your seamstress about having some extra support on loops and ties. We can''t tell you the amount of times a bustle gets torn out when a bride is on the dance floor. If your bustle does break, check out Heather''s easy instant fix to stay on the dance floor. Safety pins just won''t get the job done with a heavy material.', NULL,
    '6-9 months', false, false, NULL,
    'Quick Fix For Attire Issues', 'https://amzn.to/4pErWs4', false, NULL,
    true, NOW()
),
(
    '446ca724-dbf2-479c-b1b3-70d0e96e0bed', 'Florals & Decor', 190, 'Talk to Your Florist About Reusing Items', 'Items from your ceremony can be repurposed into cocktail hour or the reception to help save on budget. Move flowers to high top tables, at the entrance to the reception or in front of the band.', NULL,
    '6-9 months', false, true, 'Wedding Icon 108.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '1b7d9f3d-cca9-4096-816b-3fb4fdeeb754', 'Cake & Desserts', 189, 'Think About Your Cake Design', 'Picking your design can be so much fun! Buttercream designs are typically standard, but don''t be afraid to do something fun and out of the box! Heart shaped cakes are coming back, and we aren''t mad about it! Don''t forget to let your florist know if you would like fresh flowers added.', NULL,
    '6-9 months', false, true, '64.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '2334dbf9-4647-4e04-b586-3728df4af2e7', 'Blank Fun Fact', 188, NULL, NULL, NULL,
    '6-9 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '080fc67b-8209-44ec-a91e-cdbef30ceaa0', 'Stationery & Paper Goods', 187, 'Seating Chart or Escort Cards?', 'Both can offer creative options for guests to experience finding their seats - but with a tented wedding, keep in mind wind! You would not want to plan on a table of tented cards that can blow away! Did you know that an escort card is what your guest will find to direct them to the table, where they would find a place card with their name on it assigning their seat?', NULL,
    '6-9 months', false, true, '43.png',
    NULL, NULL, true, 'tented',
    true, NOW()
),
(
    'deca56b3-b25e-41c5-bc38-66734862da5e', 'Stationery & Paper Goods', 187, 'Seating Chart or Escort Cards?', 'Both can offer creative options for guests to experience finding their seats - which do you prefer? Did you know that an escort card is what your guest will find to direct them to the table, where they would find a place card with their name on it assigning their seat?', NULL,
    '6-9 months', false, true, '43.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'cfd79193-e155-485e-9f47-cfddb1b0ff78', 'Catering & Bar', 186, 'Consider a Well Rounded Cocktail Hour Menu', 'You want to make sure that there are options for guests that have different dietary needs. Vegetarian, Vegan, Gluten Free... Your guests will appreciate you.', NULL,
    '6-9 months', false, true, '62.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '3c7302e0-0894-408a-8846-734dd8b54cf8', 'Venue', 185, 'Check Overnight Policies for Venue', 'Can you leave items overnight? Or does everything need to be removed by midnight? You will want a plan in place so that you are not tasking random guests as everyone is trying to get home!', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '6d9dcabe-723d-4ec1-971d-a092195c7e06', 'ceremony', 184, 'Research Marriage Licence Requirements', 'Call your local town hall and confirm the timeline and process for applying. Each town is different so don''t skip this step!', NULL,
    '6-9 months', false, true, 'Wedding Icon 9.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'ac9d0895-571e-45a7-bd5e-b41b03a77d28', 'Logistics & Day-Of', 183, 'Talk About Day-Of Emergency Kit Items', 'Band-Aids, fashion tape, blotting papers, ibuprofen, stain remover - lifesavers. If you have a planner, they will have a massive emergency kit, so no need to go too crazy!', NULL,
    '6-9 months', false, false, NULL,
    'Best Emergency Kit', 'https://amzn.to/49tu94O', false, NULL,
    true, NOW()
),
(
    '2d877c0f-9b22-4eab-b2b2-8498f9388e8c', 'Honeymoon', 182, 'Consider Hiring a Travel Agent for Honeymoon', 'They find deals and handle logistics so you don’t have to stress. Travel Agents also have great tips and tricks for saving money and perks!', NULL,
    '6-9 months', false, true, '156.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '2ceb8562-94ac-4ceb-8941-2b632d1b5ba3', 'Blank Fun Fact', 181, NULL, NULL, NULL,
    '6-9 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '1f37b9de-f8ad-4cf4-a3e0-37a6651f5f12', 'Planning & Organization', 180, 'Start Considering Bridal Shower Themes', 'Or communicate with whoever’s hosting so they know your style!', NULL,
    '6-9 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '2663fac5-6672-4ce5-80f7-a3d8f248bd26', 'Wedding Party', 179, 'Begin Looking at Wedding Party Gift Ideas', 'Personalized gifts, jewelry, robes, flasks, tote bags, experiences. So many options to consider and keep in mind how much they have and will be doing for you!', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'c24b3aee-f796-4090-bf75-19dad9ae986f', 'music & Entertainment', 178, 'Make a Running List of “Songs That Feel Like Us”', 'It is smart to start a list of songs that you may consider for your first dance, but also songs that make you want to dance!', NULL,
    '3-6 months', false, true, 'Wedding Icon 37.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '82b9163c-2ab8-43e7-b190-291575a5d74b', 'Guest Experience', 177, 'Consider an Interactive Guest Experience', 'Photo booth, champagne tower, oyster shuckers, caricature artist, or lawn games? Heather''s personal favorite? A roaming custom cannoli bar! What a fun experience it is to be on the dance floor and a custom dessert comes walking right towards you! Did you know that there are companies that will rent mini golf putting greens duing cocktail hour too?', NULL,
    '3-6 months', false, true, 'Wedding Icon 59.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '9884b4fb-5df9-4752-af4c-4aee3b3e52fc', 'ceremony', 176, 'Start Thinking About Aisle Decor', 'Flowers flowing down the aisle? Pro Tip from Jamie - Ask your florist to reuse aisle decor in other locations to help save on budget!', NULL,
    '3-6 months', false, true, '37.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'e58795a7-2306-4240-add3-ddc44918f94d', 'Attire & Beauty', 175, 'Explore Jewelry Options', 'Earrings, bracelets, cufflinks, tie bars - this helps tie your look together. Cufflinks are a fun way to really personalize an outfit. With so many options out there, they can reflect even the fun hobbies you may love like fishing, golfing, or traveling! This is also a great way to incorporate "something borrowed" into your day.', NULL,
    '3-6 months', false, true, '99.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'd8d7dcf2-6a2a-41d5-a7c8-9016c0e858f9', 'Attire & Beauty', 174, 'Are You Wearing a Veil?', 'Consider having Veil weights on hand if you are getting married outside. They help to hold down the bottom of your veil so it''s not flying around. They are small magnets that go around the bottom edge, and they are beautiful!', NULL,
    '3-6 months', false, false, NULL,
    'Heather''s Favorite Ones!', 'https://amzn.to/45WEaoO', false, NULL,
    true, NOW()
),
(
    'c8884df4-531d-424a-b853-870233e90956', 'Blank Fun Fact', 173, NULL, NULL, NULL,
    '3-6 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'cb06cbf8-185c-4aa4-924c-1cf821744b17', 'Ceremony', 172, 'Ceremony Timing Gap?', 'Consider some activity suggestions for your guests if there is a gap between your ceremony and cocktail hour. Favorite Icecream spots work great for this!', NULL,
    '3-6 months', false, true, 'Wedding Icon 48.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '44f45f9b-f971-4689-b7ca-8f32082203b0', 'Design', 171, 'Consider Renting Lounge Furniture', 'Creates cozy spaces and elevates the reception design. We love a good speakeasy moment!', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '64ac5b49-5b19-4875-a3a7-ddadd8cd30f2', 'Miscellaneous', 170, 'Begin Drafting a Wedding Hashtag (If You Want One)', 'A unique hashtag can help keep all of your guests social media posts together - just be sure it is not being used by anyone else! Pro Tip from Heather - not a fan of social media? Create a folder where guests can upload their photos from the wedding (like Google drive) and pist QR codes at the wedding for your guests to use', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'dfe19d32-e1d0-487c-a8ce-9b99d0be4e76', 'Miscellaneous', 169, 'Look Into Weather Related Items', 'Umbrellas? Handheld fans? Blankets? Heaters? Weather is the one thing you cannot control. Think ahead to what may be helpful depending on the time of year.', NULL,
    '3-6 months', false, false, NULL,
    'Jamie''s Favorite Umbrellas', 'https://amzn.to/3YK29DV', false, NULL,
    true, NOW()
),
(
    'ffc289e5-e0e1-473e-b6fe-fa564585f063', 'Stationery & Paper Goods', 168, 'Start Thinking About Ceremony Programs', 'Totally up to you if you want to include one at the ceremony. Programs in the form of a fan is great for hot days!', NULL,
    '3-6 months', false, true, 'Wedding Icon 77.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '5ab90134-6bf5-4aad-a44a-2ee8c45c3123', 'catering & Bar', 167, 'Consider a Tea or Coffee Station', 'Especially lovely for cooler season weddings and many older guests love this with their dessert!', NULL,
    '3-6 months', false, true, '188.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '4ffb3e0d-0e51-4753-a1a7-daadf025d35a', 'Ceremony', 166, 'Begin Thinking About Ceremony Scripts', 'Your officiant will help, but you can begin shaping your story. Pro Tip from Heather - Have your officiate talk to some of your favorite married couples for advise, and have them incorporate it into your ceremony as a surprise to you! Also, don''t let them read from something ugly - their script will be in photos!', NULL,
    '3-6 months', false, true, '129.png',
    'Pretty Portfolio', 'https://amzn.to/49xpH52', false, NULL,
    true, NOW()
),
(
    'aa520efe-2cd9-466b-a5b4-06451eae770d', 'Honeymoon', 165, 'Look Into Honeymoon Attire', 'Comfort matters as much as style - sometimes more. Make sure you are preparing for the weather no matter where you are heading!', NULL,
    '3-6 months', false, true, '154.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '069c9875-895a-482b-9a38-503a78cd7163', 'Blank Fun Fact', 164, NULL, NULL, NULL,
    '3-6 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'fcc687fa-39e2-4083-917e-38f1d36f59dd', 'Guest Experience', 163, 'Review Accessibility for Guests', 'Ramps, seating, walking paths, shade, bathrooms - inclusive = thoughtful. Be clear when you communicate to your venue or catering team about special needs of guests. That way they can make sure they are prepared ahead of time to fully accomidate the guests and make everybody comfortable.', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '53219c31-a01b-41c9-8da7-c2f2c1570f63', 'florals & Decor', 162, 'Research Bouquet Preservation Options', 'Pressed flowers? Resin blocks? Book this early with your vendor - spots fill up. Make a plan for the end of the night - who should be responsibible for keeping your bouquet for it to be preserved. You don''t want to leave it behind if you have taken time to prepare plans for preservation.', NULL,
    '3-6 months', false, true, '1.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '7e63017c-f1a0-4d5a-963a-487972db5ec0', 'ceremony', 161, 'Consider Custom Vow Books', 'Simple, leather, monogrammed, or themed - they make for beautiful photos too.', NULL,
    '3-6 months', false, true, '64.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'ee527de4-787c-4a58-b739-dfa9f1fd7421', 'Ceremony', 160, 'Start Thinking About Ceremony Exit Items', 'Petals? Ribbon wands? Beach balls? Pro Tip from Heather - make sure to ask your venue for approval, some have rules around this for clean up purposes.', NULL,
    '3-6 months', false, true, 'Wedding Icon 116.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'f9b1d47f-751a-470f-8432-65fd8a4baf4f', 'Stationery & Paper Goods', 159, 'Research Custom Signage Options', 'Acrylic, wood, canvas, mirror signs - match your aesthetic and find a vendor that can create something amazing for you!', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '0139973b-b46d-4d6f-857f-bcc0bed19e08', 'Logistics & Day-Of', 158, 'First Kiss Tip!', 'Think about your first kiss moment...and practice it! Espcially for photos and if you are going to do a dip!', NULL,
    '3-6 months', false, true, '19.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'd566dfea-2275-4ea4-ba0d-6e2fb715cbc6', NULL, 157, NULL, NULL, NULL,
    '3-6 months', true, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '48d325f6-fc1f-403e-9edb-47bf60a2a490', 'ceremony', 156, 'Think About Whether You Want a Receiving Line', 'Classic but time-consuming. Many couples skip it. Say hello at your cocktail hour works just as well.', NULL,
    '3-6 months', false, true, '56.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '60615fc9-167a-4dbd-88e0-4ef4b0dd6de9', 'Miscellaneous', 155, 'Having Kids at the Wedding - Consider Hiring a Babysitter', 'A lifesaver for parents who want to enjoy the party. You can also just recommend a local babysitting service if you do not want to cover the cost!', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '3f14f1ce-4e4f-42f5-8e80-c954b59deb3a', 'Attire & Beauty', 154, 'Start Planning Wedding Party Attire Shopping Date', 'Colors, styles, ordering timelines - wrangling adults is harder than it looks.', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '0f4ee2ca-ce75-49ef-b265-84e487b400ec', 'Blank Fun Fact', 153, NULL, NULL, NULL,
    '3-6 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'e1cca60b-af84-4c4c-9bf7-ef918b0997c0', 'Catering & Bar', 152, 'Look Into Custom Cocktail Napkins', 'Names, initials, pets, fun quotes - small detail, big delight. When ordering, you want to plan on 4-5 per person. This should cover you well into the evening, before the dance floor opens up. Be clear with your catering team if they are to be used for just cocktails, or passed apps too.', NULL,
    '3-6 months', false, true, '62.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '424551dc-bbf5-4796-bfeb-db42811c549b', 'Cake & Desserts', 151, 'Decide If You Would Like Your Band or DJ to Announce a Cake Cutting', 'Do you want it to be announced to all the guests, or do you want to cut it off to the side with just your photographer? We love it either way.', NULL,
    '3-6 months', false, true, '66.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'f552cca7-3ea8-408e-9c38-66869c406547', 'Planning & Organization', 150, 'Begin Planning Your Morning-Of Timeline', 'Hair, makeup, breakfast, photos - morning chaos is real and so is planning ahead for a busy morning!', NULL,
    '3-6 months', false, true, '90.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'b3d22319-b484-442c-b325-54749b331c33', 'Attire & Beauty', 149, 'Order After Party Outfits', 'Comfy jumpsuit? Mini Dress with feathers? We are here for all the looks. Make sure you include a change of shoes if you''re planning for a new outfit - heels are no fun after 8 hours. Light up sneakers for the dance floor? Don''t forget socks as well, they are often overlooked when packing your bag!', NULL,
    '3-6 months', false, true, 'Bow 3.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'f0f8c7f7-a326-4e4e-917e-6fef17e7c498', 'Photography & Videography', 148, 'Consider a Recessional Moment (or Moments!)', 'Petals toss? Bubbles? Dramatic Dip? You will be making your exit as a married couple - make it fun!', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '76d0a8d8-adb3-4987-bd71-2a487a673693', 'Reception', 147, 'Decide on Dance Floor Props', 'Glow sticks, LED batons, sunglasses - optional but fun! Seeing the joy on the guests faces when you walk towards them with a basket full of light up props is a true highlight of the evening. Adults turn back into kids pretty quickly, and it''s pretty great.', NULL,
    '3-6 months', false, true, '24.png',
    'Guests love to glow!', 'https://amzn.to/462oCzT', false, NULL,
    true, NOW()
),
(
    'ab29336f-d442-4649-9cb2-83aee39ac314', 'Attire & Beauty', 146, 'Begin Coordinating Parent Attire', 'Give them general guidelines so everyone looks cohesive in photos and so the moms don''t look like bridesmaids!', NULL,
    '3-6 months', false, true, '111.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '850bd519-4962-4859-9fc4-a432a08c33af', 'Logistics & Day-Of', 145, 'Are You Exchanging Private Vows on Wedding Day?', 'Make sure that you tell your photo and video team where and when this is going to take place if you want it captured.', NULL,
    '6-9 months', false, true, '64.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'fb2cd999-0d4e-425d-84dd-990f19c9ff76', 'Catering & Bar', 144, 'Research Alcohol Quantities', 'If you’re purchasing your own alcohol, calculate amounts early. Your catering team or venue can help with this!', NULL,
    '3-6 months', false, true, 'Martini 1.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '2b6cbbcb-5666-4621-bdbe-b24bdeafb979', 'Catering & Bar', 143, 'Start Thinking About Rehearsal Dinner Decor', 'Simple tablecloths, candles, florals - small touches go far. Pro Tip from Heather - Ask your florist if you can reuse flowers from your dinner at cocktail hour the next day! Save the budget!', NULL,
    '3-6 months', false, true, 'food tray 1.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '6ddc9375-1fdf-4464-ac33-ec119b290f92', 'Attire & Beauty', 142, 'Schedule Any Groom/partner Attire Alterations', 'Tailoring takes longer than expected, best to schedule now!', NULL,
    '3-6 months', false, true, '120.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'bd42c3a4-dd59-40f5-a308-51258b6af5c6', 'Blank Fun Fact', 141, NULL, NULL, NULL,
    '3-6 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '1593376b-f4f8-460f-8262-29b1364f58ec', 'Catering & Bar', 140, 'Think About Guest Flow During Cocktail Hour', 'Where do they put their drinks? Where do they mingle? Are there bottlenecks? Consider where you are placing popular items like food stations. You want to make sure there is plenty of space around them, and not near the bar, so a back up doesn''t happen. Make sure your gift table is one of the first that the guests walk by, they will be looking for a place to drop their cards off for you.', NULL,
    '3-6 months', false, true, 'wine glass with bow 4.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'a3d4f1aa-043b-414a-b4eb-418becf722b8', 'Legal & Admin', 139, 'Research Marriage License Requirements in the State You Are Getting Married', 'How early you can apply, what you need, waiting periods - varies by state/town.', NULL,
    '3-6 months', false, true, '64.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '07164e51-9544-4168-80d3-886351bbaa49', 'Transportation', 138, 'Consider Hiring a Ride-Home Shuttle', 'If you do not want to invest in transportation all evening, consider just a ride home - guests will thank you (and avoid irresponsible decisions).', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '573ad20f-3f5d-441e-947a-e88f647f045b', 'Florals & Decor', 137, 'Consider Wind for Outdoor Decor', 'Secure any signage or light items. It never hurts to keep a bit of extra space inside your tent incase you need to bring any light weight items in due to wind.', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, true, 'tented',
    true, NOW()
),
(
    'd7f5b7a3-afbf-4ef4-ac83-ed3ab271938b', 'Florals & Decor', 137, 'Consider Wind for Outdoor Decor', 'If you are having anything outside, be sure to plan to secure any signage or light items like escort cards! They tend to fly away easily!', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '8cb03c0b-2ef8-4930-9742-c2290105bbe3', 'Miscellaneous', 136, 'Create a Wedding Day Packing List', 'Start a note or google doc where you can list out the things you will need on wedding day - shoes, perfume, custom hangar, jewelry, vows, rings - get it all in one spot.', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '1858e831-1e35-4383-af00-f7b8440f30c8', 'Photography & Videography', 135, 'Decide If You Want to Display Childhood Photos', 'This could be a fun element to include at the rehearsal dinner or welcome party!', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'ff162328-4fad-409c-94c6-d4c486ea0c37', 'ceremony', 134, 'Start Planning the Ceremony Processional Order', 'Think through who is walking when and what guests are processing besides you and you''re wedding party - grandparents, kids, pets?', NULL,
    '3-6 months', false, true, '37.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '44e02225-eaf1-4596-9b61-d8277fab4d54', 'Miscellaneous', 133, 'Schedule a Trial Spray Tan Session', 'Planning to get a spray tan for the wedding? Be sure to do a trial run if you are trying out a new location - especially if it is a location near your venue and not where you live!', NULL,
    '3-6 months', false, true, '90.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '12ba248d-90ae-4f86-b5a8-4d76a5dd57d7', 'Ceremony', 132, 'Start Thinking About a Post-Ceremony Private Moment', 'Just 2–3 minutes alone to breathe. Pro Tip from Jamie - It is great to step away, have a bite to eat and bustle your dress. Then you can head to cocktail hour without worrying about what you can get to eat or moving around with your train!', NULL,
    '3-6 months', false, true, '133.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'dc56c74a-5973-499e-b030-4107d71d03f8', 'Photography & Videography', 131, 'Decide If You Want a Photo Booth', 'Photo Booths are a great activity and favor for your guests. Think through if you want one and what style you like. Disposable cameras are also making a comeback!', NULL,
    '3-6 months', false, true, '166.png',
    'Funny Props', 'https://amzn.to/4b8YQxp', true, NULL,
    true, NOW()
),
(
    '0b9895ef-243a-4e82-89d3-22fe7f28d18f', 'Blank Fun Fact', 130, NULL, NULL, NULL,
    '3-6 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '5b27c0d5-5233-4dde-b123-7674c2fc3534', 'Attire & Beauty', 129, 'Gather Shoes and Undergarments for Fittings', 'You want to make sure that hem and fit are all correct, and nothing can be seen through outfits', NULL,
    '3-6 months', false, true, '89.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'bc3569c6-59d1-4f5d-bda9-a0fb736e625b', 'guest Experience', 128, 'Plan for Guest Sun Protection', 'Parasols, sunscreen baskets, shade umbrellas - especially for summer weddings.', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'f710fc78-5785-4d6d-b65d-639577ebf9bb', 'Guest Experience', 127, 'Think About How Guests Will Drop Off Their Cards and Gifts', 'Card box? Vintage suitcase? Make sure to designate somebody to be in charge of this for you so you don''t have to worry at the end of the night!', NULL,
    '3-6 months', false, true, '45.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '4ecf8f78-12a5-45d4-a484-a5838fdd6df2', 'Guest Experience', 126, 'Decide on Bridal Shower Guest List', 'Be sure to get this list ready for your host and send ahead of time so they are not tracking you down!', NULL,
    '3-6 months', false, true, '178.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'd518efc9-e7d2-4dd3-810c-ef92312df57c', 'Ceremony', 125, 'Make Your Ceremony Personal', 'Fun Tip From Heather! Have your officiant talk to your favorite married couples and ask them for their best marriage advice and wishes for you. Have it be included as a surprise to you. We all love sweet surprises, right?', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'fac5d3ed-0b87-41d1-8bef-02e1d9138644', 'Catering & Bar', 124, 'Research Your Caterer’s “Allergy-Friendly” Options', 'Make sure they can accommodate your guests safely. Make sure you are asking for allergies on your guest RSVP cards or website.', NULL,
    '3-6 months', false, true, '80.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '2578050d-2ce7-4caa-8d1e-82fdff2ea4f1', 'Catering & Bar', 123, 'Think About Rehearsal Dinner Invites', 'Rehearsal dinner invites can be included as an additional piece to certain guests in you''re wedding invitation, a separate mailing altogether or a digital option. Review with the host how they would like to handle it before assuming!', NULL,
    '3-6 months', false, true, '170.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '7aeca057-23d1-424a-bdc3-e0e42a637cf8', 'ceremony', 122, 'Begin Planning Your Ceremony Layout', 'How do you picture standing at the end of the aisle and where do readers stand? Which side of the aisle do you want to stand on and where will parents sit? Consider all of the details!', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '68ac7e1c-8283-4009-80ab-26c96a81564d', 'Design', 121, 'Start to Think About Your Seating Assignments', 'Ask your catering team how many guests can sit at each table, and start to put groups of guests together for those tables. Pro Tip from Heather! Make sure you consider tent openings, heater locations, or loudspeakers under the tent when choosing where grandparents are going to sit!', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, true, 'tented',
    true, NOW()
),
(
    'df31ccbc-780f-4a44-a3eb-f92f355c6cb9', 'Design', 121, 'Start to Think About Your Seating Assignments', 'Ask your venue how many guests can sit at each table, and start to put groups of guests together for those tables.', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '1823f7ae-0adb-4b41-84db-dfca1df06f8b', 'florals & Decor', 120, 'Consider Personal Touches', 'Planning on having childhood photos, memory table photos, or other personal touches? Gather them early and pack for safe keeping.', NULL,
    '3-6 months', false, true, 'Wedding Icon 108.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '3641c97a-4eab-403c-ba33-0450778c871e', 'Logistics & Day-Of', 119, 'Discuss Whether You Want a “First Touch”', 'Think about first look and/or first touch moments. Would you rather see each other before the ceremony or just touch hands around a corner? Remember that first touch moments to do not allow for photos before the ceremony!', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'd2aa2cb9-58b4-4a13-8993-a6ea0a84c6fc', 'Blank Fun Fact', 118, NULL, NULL, NULL,
    '3-6 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'd6cc3080-4d3b-47c0-a753-9f8c688c2615', 'ceremony', 117, 'Confirm the Time of Your Ceremony Rehearsal', 'Make sure you know what time to practice, and who you need to be there with you! Let you''re wedding party know ahead of time so they can plan accordingly!', NULL,
    '3-6 months', false, true, '56.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'b37fa1a9-b944-4fdf-a0ab-aae51c386864', 'Music', 116, 'Consider a Private Last Dance', 'A sweet, emotional moment - and a great way to reset before the exit. Here we go!', NULL,
    '3-6 months', false, true, 'Wedding Icon 95.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'ca7421e5-e04e-403f-b3cc-bcb5c239a6f8', 'ceremony', 115, 'Think About Aisle Markers for Reserved Families', 'Ribbon, florals, or signage. It helps to reserve rows so there is no confusion at the top of the aisle!', NULL,
    '3-6 months', false, true, '37.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'df3601ff-043c-48ae-ba96-4f372b0ae7ec', 'Blank Fun Fact', 114, NULL, NULL, NULL,
    '3-6 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'f1c2c67c-7a27-4a6f-ba66-bdd3194a04eb', 'Transportation', 113, 'Begin Planning Guest Transportation Arrival Windows', 'Getting guests to the ceremony on time is… an adventure. Transportation planning is not glamorous, but necessary!', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '4e6299d3-a844-41c2-8d71-ab72c2727c42', 'Ceremony', 112, 'Create a Ceremony Weather Backup Plan', 'If you choose to have everything under your main dinner tent, you can have guests sit right at their dinner tables. Create a few rows on your dance floor for the VIPS! if you have a rain back up tent on hold, even better!', NULL,
    '3-6 months', false, true, 'Wedding Icon 97.png',
    NULL, NULL, true, 'tented',
    true, NOW()
),
(
    '3f4f51fe-62c5-43af-b5d0-da863921de48', 'Ceremony', 112, 'Create a Ceremony Weather Backup Plan', 'All venues should have a weather back up plan for your ceremoy, confirm the details with your venue manager ahead of time so you know what to expect.', NULL,
    '3-6 months', false, true, 'Wedding Icon 97.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'd535833a-d208-47fc-a2b6-18c661a4f46d', 'Photography & Videography', 111, 'Begin Planning Photo Locations', 'Think through where you envision your photos throughout the day - first look, wedding party, family photos. Make a list of both primary and bad-weather options.', NULL,
    '3-6 months', false, true, '42.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'e80fa6f6-498e-4ce4-870e-e9704a563ac0', 'Catering & Bar', 110, 'Confirm When Final Meal Counts Are Due', 'Make sure you ask your venue or catering team when your food count deadline is and then plan to send it to them a couple of days before so you are ahead of the game!', NULL,
    '3-6 months', false, true, '157.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '5751993b-d3eb-4eb7-94bf-5b5fde5c6bab', 'Wedding Party', 109, 'Consider Getting Silk Robes or Matching Outfits for the Girls Getting Ready', 'This is a really fun addition and can second as a gift! It also makes for great getting ready photos!', NULL,
    '3-6 months', false, false, NULL,
    'The Best Slippers', 'https://amzn.to/4a324Bx', false, NULL,
    true, NOW()
),
(
    'f6ed42a7-10e4-4fb9-834c-28e40272946e', 'Guest Experience', 108, 'Clearly Communicate Dress Code to Guests', 'This can be added to your website. Guests feel more comfortable if they know what to wear. Pro Tip from Jamie - Let ladies know if they are going to be on grass, sand, or flooring - helps to make decisions on heels!', NULL,
    '3-6 months', false, true, 'Wedding Icon 99.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'fa22742f-1300-408a-a03c-836768b297eb', 'Ceremony', 107, 'Finalize Ceremony Readings (Final Version)', 'Lock it in so your officiant can prepare the script. Make sure all readers have copies of their readings.', NULL,
    '3-6 months', false, true, 'Wedding Icon 55.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'e5f0e4c8-88bc-40bb-b61d-5ba245bec24e', 'Blank Fun Fact', 106, NULL, NULL, NULL,
    '3-6 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '50c25589-dd2b-4616-bb01-0d9a358e49ef', 'Guest Experience', 105, 'Start Thinking About Guest Flow After the Ceremony', 'After you say "I Do" where will your guests go? Be sure to map out the flow and let you''re wedding party know ahead of time. Pro Tip from Jamie - Make sure to greet your guests with a beverage after the ceremony!', NULL,
    '3-6 months', false, true, 'Wedding Icon 47.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'c1082836-03ce-4d98-8ce7-97677b07d77a', 'Ceremony', 104, 'Confirm Sound System for Your Ceremony', 'Be sure to confirm what you need and who is providing this! Make sure you have access to power if you are outside!', NULL,
    '3-6 months', false, true, 'Wedding Icon 83.png',
    NULL, NULL, true, 'tented',
    true, NOW()
),
(
    '51855903-c736-491e-903b-e9a4ac87b587', 'ceremony', 104, 'Confirm Sound System for Your Ceremony', 'Be sure to confirm what you need and who is providing this! Pro Tip from Heather - Your entertainment can typically provide the for you!', NULL,
    '3-6 months', false, true, 'Wedding Icon 83.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '7aed4cc3-3a6f-41c9-ae39-a8e2dc02dbf9', 'florals & Decor', 103, 'Finalize Your Flower Color Palette and Choices', 'Your florist will love you for doing this early. Make sure to ask them of any deadlines you must meet for ordering.', NULL,
    '3-6 months', false, true, '1.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '561aa6cd-161b-4fdb-8b2a-d5dd3a3937f3', 'Stationery & Paper Goods', 102, 'Look Into Place Card Options', 'Paper cards, shells, acrylic pieces, mini bottles - endless styles. Pro Tip from Jamie - if you are assigning seats, you can create personalized menu cards with the name of the guest at the top of his or her menu - reminding them what they ordered and assigning their seat', NULL,
    '3-6 months', false, true, '43.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '97bd32d3-6f7f-4b70-a9b1-288f332f6835', 'Reception', 101, 'Start Thinking About Speeches and Toast Order', 'There will be many important people that will like to share a few words on you''re wedding weekend. Think through who makes sense to take the mic and when you want them to do so. We recommend no more than 3 toasts on wedding day!', NULL,
    '3-6 months', false, true, '61.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '167ebc35-997f-459b-8151-76d599ab0d2b', 'Music & Entertainment', 100, 'Finalize “Do Not Play” Songs', 'Yes, this is where you ban the YMCA or Uptown Funk once and for all.', NULL,
    '3-6 months', false, true, 'Wedding Icon 34.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '9001e249-6a85-44f2-b8e7-bff6acd13dbb', 'Photography & Videography', 99, 'Create a List of “Special Items” for Your Photographer', 'Shoes, jewelry, vows, perfume, heirlooms - gather them in one box for day of photos.', NULL,
    '3-6 months', false, true, 'Wedding Icon 58.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '4640bf57-d370-40ef-a1f1-706d7bd7dddc', 'Honeymoon', 98, 'Book Honeymoon Spa Services', 'Who doesn''t love a relaxing massage or facial while on vacation? Plan it now and your future self will thank you later!', NULL,
    '3-6 months', false, true, 'Wedding Icon 27.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '30e88510-de0a-4885-a567-8ac4d73e50cc', 'Blank Fun Fact', 97, NULL, NULL, NULL,
    '3-6 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '08be55da-a812-426d-baf8-458c266c0e77', 'Ceremony', 96, 'Finalize Ring Bearer and Flower Girl Plans', 'If you are including flower girls or ring bearers, be sure to have a plan in place for the kiddos from what they are wearing or carrying and who is getting them down the aisle and at the end of the aisle!', NULL,
    '3-6 months', false, true, 'Wedding Icon 16.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'a93f7a52-7fdb-4b67-b895-e818ae52c017', 'Florals & Decor', 95, 'Choose Your Napkin Fold Style', 'You never thought you would have to decide on a napkin fold, did you! There are many options so ask your venue or caterer what they suggest!', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'f7c76567-82a3-4ebe-a504-83110451ef5d', 'Attire & Beauty', 94, 'Choose Jewelry for Wedding Day', 'Simple? Statement? Something borrowed? Start collecting pieces and bring them to your final fitting.', NULL,
    '3-6 months', false, true, '99.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'c5078ebf-2945-4b21-9819-a89c113a8062', 'guest Experience', 93, 'Start Planning Wedding Weekend Welcome Bags', 'Snacks, water, maps, mini Advil, sunscreen, local treats. Make sure you also figure out when and where you will put them together the week of the wedding!', NULL,
    '3-6 months', false, true, 'Wedding Icon 78.png',
    'Sweet & Simple', 'https://amzn.to/463QCTN', true, NULL,
    true, NOW()
),
(
    '125c4d5e-f64b-4b86-b0a0-24e1dbd3c062', 'Transportation', 92, 'Review Shuttle Timelines', 'How many loops? Pickup times? Drop-off spots? Expect delays and plan for load in/load out time. It can be very helpful to collect information on your RSVPs for this. Ask guests if they plan to take shuttles and where they are staying. This will help you set up a successfull plan for where shuttles are going and when. Make sure to communicate this to your guests on your website.', NULL,
    '3-6 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'c53e4b9f-489f-4c17-8b15-153a3bbc7e89', 'Logistics & Day-Of', 91, 'First Kiss Tips!', 'Make sure to hold your kiss for at least 3 solid seconds so the photographer can get a great shot of it! Remind your officiate to scoot out of the way so they are not awkardly in your photos. Bonus: Stop halfway down the aisle for another smooch! (your photographer will thank you!)', NULL,
    '3-6 months', false, true, '19.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'd440b937-743a-4dda-bc52-a4ced8261140', 'Venue', 90, 'Confirm an Onsite Technician for Your Tent', 'Many companies won''t offer this right away, but know you can always ask. If it starts to rain, they can quickly put up the walls of your tent so you''re not stuck with them up or down. They can also help with any last minute issues like loose tent spikes on a windy day', NULL,
    '1-3 months', false, true, '36.png',
    NULL, NULL, false, 'tented',
    true, NOW()
),
(
    '79724e03-7ad2-4709-96fc-1227c15caa84', 'Blank Fun Fact', 90, NULL, NULL, NULL,
    '1-3 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'e8ba404a-986f-47c5-a82a-8385d6a3ab5a', 'Guest Experience', 89, 'Finalize Ceremony Seating Assignments', 'Who sits in first row? Family dynamics matter here. It''s great to have your first few rows full for photo purposes.', NULL,
    '1-3 months', false, true, '48.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '51bf8a53-d21f-427c-a1f6-32e5edb568cb', 'Miscellaneous', 88, 'Determine Who Will Hold the Rings', 'This is a big job! Determine who will hold the rings during the ceremony. Pro Tip from Jamie - do not use real rings for your ring bearer if they are young! No one wants to find where the rings went after they were swinging the pillow around their head!', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'b4f56892-6239-4588-a394-aaba564a7215', 'Catering & Bar', 87, 'Decide What Happens to Leftover Food/Desserts', 'If the venue or caterer allows for you to take home any leftover food, what will you plan to do with it? Donate? Give to staff? Pack for brunch? Plan ahead.', NULL,
    '1-3 months', false, true, '80.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '94be3683-9461-4195-891c-246b0ec4508f', 'Music & Entertainment', 86, 'Create Your Getting-Ready Playlist', 'Empowering hype? Relaxing acoustic? Mix of both? Set the tone. Pro Tip from Jamie - task this to a friend or family member and be surprised by a fun getting ready playlist!', NULL,
    '1-3 months', false, true, 'Wedding Icon 37.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'ea5eaf85-2fa2-435d-9f49-270188c22630', 'Transportation', 85, 'Start Thinking About Your Wedding Exit Transportation', 'Getaway car? Boat? Vespa? Golf cart? Vintage Jeep? Or just take off with your guests! Consider your photographer''s schedule too, if you would like them to be there to catch those fun last minute details of the evening. They often depart before then, so plan ahead!', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '4c098392-6129-4f52-abe7-20a8411f6c07', 'Wedding Party', 84, 'Finalize Wedding Party Shoes and Accessories', 'Coordinated or mismatched - choose your look. Make sure you consider if you are going to be on grass or uneven ground!', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'a09711bd-3507-400e-9c36-c0fbd58de8dc', 'Blank Fun Fact', 83, NULL, NULL, NULL,
    '1-3 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '9398f21f-cc09-4126-ac61-52f71aa6ac69', 'Miscellaneous', 82, 'Think About Personal Letters or Gifts for Each Other', 'If you want to exchange gifts with your financè, be sure to discuss this ahead of time and have a plan to exchange. It is great to discuss a budget as well!', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '8bd91eb0-2321-41d3-9a66-fa9474fcdaea', 'Attire & Beauty', 81, 'Decide on Your Wedding Day Nail Color', 'Neutral? Bold? Classic French? This is a great excuse for a weekly manicure to try out the colors you like. Knowing your shade of dress can help too! Not all dresses are bright white, which may be good to consier when choosing your nail color.', NULL,
    '1-3 months', false, true, 'Bow 3.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '11717098-b42d-4b7e-9fca-d9f31c96deca', 'florals & Decor', 80, 'Preserving Your Bouquet After the Wedding?', 'Make sure to designate one person who will be responsible for saving your bouquet and make plans for how to get it where it needs to be after the wedding. You don''t want to forget it at your venue!', NULL,
    '1-3 months', false, true, '1.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '62dbda0d-5a03-4bb4-a634-bfe3c552d6f4', 'Catering & Bar', 79, 'Finalize Menu Add-Ons', 'Bread boards? Grazing table? Raw bar? Dessert shooter wall? We are here for all of it. Add-ons are a great place to include vegetarian, vegan, or gluten-free options without overhauling the main menu. Pro Tip from Heather - Not everyone will eat dessert or a late-night snack. Ask your caterer or venue for recommended quantities so you’re not over-ordering.', NULL,
    '1-3 months', false, true, '59.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'c3324307-fd5f-4941-a545-269de2d6e88b', 'Ceremony', 78, 'Confirm Ceremony Microphones', 'Lavalier mics? Officiant-only? Guests need to hear you. Pro Tip from Heather - Nobody wants a mic stand in their photos... Lavalier is best. Avoid handheld at all times, they look awkward in photos, are hard to hold, and distract from the moment. Make sure to add on a stand mic off to the side if you have any readers that will need them too.', NULL,
    '1-3 months', false, true, 'Wedding Icon 84.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'd13ba47d-0fec-4ba5-8a67-d1116acf7a29', 'Planning & Organization', 77, 'Begin Drafting Your Final Timeline', 'Just about two months out and not much should be changing after this! Spend some time ironing out the final details with your fiancé and planner.', NULL,
    '1-3 months', false, true, '90.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '358a21c5-2326-49fa-a8b1-6db4cdfba0f0', 'Florals & Decor', 76, 'Plan Your Escort Card Display', 'Beautiful yet function is the way to go. Nobody loves a traffic Jam', NULL,
    '1-3 months', false, true, '43.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'd4b4fb75-77dd-451e-a929-72ffbda0a201', 'Guest Experience', 75, 'Amenity Basket Hot Item Alert!', 'Nobody wants bad breath. Order a bag of mints for your bathroom amenity baskets.', NULL,
    '1-3 months', false, false, NULL,
    'Feel Fresh All Night', 'https://amzn.to/3Nk9mIo', false, NULL,
    true, NOW()
),
(
    'da6cd313-69e7-459f-836f-91daf151d00f', 'Photography & Videography', 74, 'Think About Special Photo Moments Throughout the Day', 'Besides your typical moments, consider a first look with your parents, a room reveal with just the two of you before all guests arrive or a private last dance.', NULL,
    '1-3 months', false, true, '42.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'a8058c49-de33-4d4f-a6a7-08d88b739a3c', 'Catering & Bar', 73, 'Think About Food During Photos', 'Ask your catering team if they will provide you with a "bridal tray" of all the yummy cocktail hour apps while you are off taking photos. You don''t want to miss out - or be hungry!', NULL,
    '1-3 months', false, true, '52.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '435039dd-1dce-4eb0-8b02-7736294b55bb', 'Miscellaneous', 72, 'Finalize Your Wedding Hashtag (If Using One)', 'Double check that it is not in use by anyone else and be sure to post somewhere at the wedding so guests use it!', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '0423875c-f8b2-4743-9747-e8503bdc7080', 'Blank Fun Fact', 71, NULL, NULL, NULL,
    '1-3 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '77b72b1a-5ad2-4c1e-a342-8d47a681545d', 'Attire & Beauty', 70, 'Make a Wardrobe Inventory List', 'You won''t believe the amount of times a groom has forgotten a tie, or a bride has left her dancing shoes at home!', NULL,
    '1-3 months', false, true, '114.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'a9163948-bb55-46a7-a6d9-4ad0b1065c45', 'Guest Experience', 69, 'Review Your Guest List for Missing Info', 'Kids’ ages, dietary restrictions, last names, updated addresses.', NULL,
    '1-3 months', false, true, 'Wedding Icon 1.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '679c55d4-48d7-4ed6-8240-6409e0e8f52f', 'Florals & Decor', 68, 'Plan Decor Set up and Take Down Logistics', 'Assign who does what and when. Check with your venue if there are guidelines or restrictions that you need to follow.', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '3fcfb7b7-d863-41a9-ad50-64aa2e799713', 'Stationery & Paper Goods', 67, 'Decide How to Display Your Signage', 'Look into fun ways to display and purchase ahead of time of ask your venue if they have easels you can borrow. Many do from past clients leaving them, and it''s one less thing you need to transport.', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '7ec698f8-6e2f-4af6-97f6-f5eb131e6fbd', 'Music & Entertainment', 66, 'Have a Dance Party!', 'Take your list of songs that you want to hear at the wedding and have a dance party to make sure all of the songs on your list are truly "dance floor worthy" - a ton of fun and a way to let loose and shake off some stress!', NULL,
    '1-3 months', false, true, '31.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'a95847b5-0008-4667-9775-289ed54beca4', 'Cake & Desserts', 65, 'Decide on Cake Cutting Music', 'It sounds silly, but it’s a whole moment. Or if the spotlight is not for you, opt for a "stealth" cake cut with no music or announcement, just you, your photographer and a bite of cake!', NULL,
    '1-3 months', false, true, '66.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '032b732d-4eb2-47b1-a1c5-e3729739f3e0', 'Design', 64, 'Make Any Last Minute Adjustments to Your Floor Plan Design', 'Sometimes tables need shifting to make it all fit. Or to keep certain guests away from each other. We totally get it all.', NULL,
    '1-3 months', false, true, 'Wedding Icon 127.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '206e9690-dd57-47eb-99bb-37a407c4cf1f', 'Attire & Beauty', 63, 'Decide Who Is Going to Help You Bustle Your Dress', 'Make sure you share any videos or tips from your seamstress - different bustles can bring different challenges!', NULL,
    '1-3 months', false, true, '114.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '941a21b7-cff7-406d-b016-34d965f1ec9c', 'wedding Party', 62, 'Start Organizing Wedding Party Gifts', 'Reconfirm everything you have - how are you packaging it, when are you gifting them to you''re wedding party?', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'a508aec4-b5cc-4479-a0b5-8f934b7bd6af', 'Blank Fun Fact', 61, NULL, NULL, NULL,
    '1-3 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '14703707-ded1-48c7-bed1-6bbfcff4627d', 'vendors', 60, 'Confirm Vendor Meal Requirements', 'Check in with your vendors to confirm number of meals needed and any dietary restrictions. Share with your venue or caterer and they will manage it for you!', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '347f1b6e-8154-4950-8b1c-35e9dff356c3', 'Attire & Beauty', 59, 'Schedule Your Spray Tan', 'Make sure you test out any products before the big day, and schedule your spray for 3-4 days prior to the wedding.', NULL,
    '1-3 months', false, true, '86.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'cde0ae45-41c8-4993-b0e5-802d2330f2d6', 'Photography & Videography', 58, 'Begin Planning Your Photo Timeline with Your Photographer', 'Family photos, couple portraits, group shots - map it out early and review what really matters to you and your fiancé and family. Your photographer will review this with you on your final call', NULL,
    '1-3 months', false, true, '90.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'eb7fcc43-c998-4739-b545-eb9b2222b25b', 'Ceremony', 57, 'Finalize Ceremony Script with Officiant', 'Read it through together to ensure the tone and tempo feels right. Add anything you feel is missing and remove anything that doesn''t work.', NULL,
    '1-3 months', false, true, 'Wedding Icon 116.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'c91dd8f2-b097-412e-95bf-cd101422f455', 'Planning & Organization', 56, 'Review Timeline with All Vips', 'Wedding party, parents, anyone with a role - get everyone aligned early. Pro Tip from Jamie - consider making a specific timeline for your VIPs so that they do not get lost in the details of the day, just the details they need to know!', NULL,
    '1-3 months', false, true, '90.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '8699379d-e4b5-430b-88d3-d3d4e4b7e0ad', 'Transportation', 55, 'Confirm Shuttle and Transportation Schedules', 'When your RSVPs are in and you know where guests are staying, double-check routes, timing, and passenger counts.', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '02979e4f-6395-4ce0-bf92-36e20583cace', 'Logistics & Day-Of', 54, 'Prepare a Day of Emergency Kit', 'Stain remover, Advil, deodorant, lash glue, safety pins - the works. If you have a planner, they will have a massive emergency kit, so no need to go too crazy!', NULL,
    '1-3 months', false, false, NULL,
    'Great little kit!', 'https://amzn.to/4t3Wx5o', true, NULL,
    true, NOW()
),
(
    '54efe1bc-60de-4cf4-8ce2-9726cfeaa16f', 'Attire & Beauty', 53, 'Final Dress and/or Suit Fitting', 'Try everything on together - shoes, accessories, veil - make sure the full look is perfect.', NULL,
    '1-3 months', false, true, '111.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '316f911f-8edd-4b00-bb99-ea1cdd7497fd', 'budget', 52, 'Confirm All Final Vendor Payments', 'Avoid day-of stress by paying early. Your vendors will have different due dates - make sure to keep track of them.', NULL,
    '1-3 months', false, true, 'checklist.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '80c7a7c8-24e6-49fa-9980-40efca822112', 'Guest Experience', 51, 'Amenity Basket Hot Item Alert!', 'Please don''t forget a small sewing kit. Something will break, help your guests out.', NULL,
    '1-3 months', false, false, NULL,
    'This is our favorite!', 'https://amzn.to/4qQoITd', false, NULL,
    true, NOW()
),
(
    'a858a34e-89bc-4b3d-a28e-81b308e375f2', 'Florals & Decor', 50, 'Organize All Decor Items', 'Sort by event (ceremony, cocktail, reception) and label each bag or box. Pro Tip from Heather - Storing all these items in a clear bin helps your coordinator set up, and then pack up for you at the end of the evening.', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '4325d4bd-207d-477e-9ba9-cc9281454346', 'Planning & Organization', 49, 'Create a Rain Plan Version of Your Timeline', 'Same structure, different locations - just in case. Also note anything needed for the rain plan - umbrellas, coat racks, etc.', NULL,
    '1-3 months', false, true, '90.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'ed1962f1-fefa-41ef-9b31-cf9d243709f3', 'Blank Fun Fact', 48, NULL, NULL, NULL,
    '1-3 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'cfc606fa-f9cd-4469-a3ac-be180901ce46', 'Planning & Organization', 47, 'Plan Where You’ll Store Gifts and Cards', 'Determine where this will be in the room at the venue and then delegate someone trustworthy to be in charge of handling them at the end of the night.', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '1c7a93c0-a389-41ee-bb98-0e704296e8ab', 'Budget', 46, 'Prepare Tip Envelopes for Vendors', 'Label with names and hand off to your planner or a trusted VIP. They can hand them out for you on wedding day - one less thing on your plate!', NULL,
    '1-3 months', false, true, 'dollar_sign.png',
    'Cute Envelopes', 'https://amzn.to/4qX41oF', true, NULL,
    true, NOW()
),
(
    'e74fcd8b-f145-405b-94b6-fe418abf793a', 'Music & Entertainment', 45, 'Send Final Playlist Notes to Your DJ or Band', 'Your “must plays” and “do not plays” should be crystal clear by now. Pro Tip from Heather - Hand out some fun dance floor props when the sun goes down! Trust us - Adults love them more than kids! Check out our favorite ones!', NULL,
    '1-3 months', false, true, 'Wedding Icon 90.png',
    'Don''t Forget These!', 'https://amzn.to/4qRJhyz', true, NULL,
    true, NOW()
),
(
    '8545706e-38c3-4bfd-b41d-5862e530a805', 'Attire & Beauty', 44, 'Continue to Break in Your Wedding Shoes', 'Wear them around the house while doing dishes. Yes, really!', NULL,
    '1-3 months', false, true, 'Wedding Icon 93.png',
    'These work best!', 'https://amzn.to/4qRJhyz', false, NULL,
    true, NOW()
),
(
    'c1f3af1d-468d-497e-8b98-50ee15258859', 'wedding Party', 43, 'Send a Group Email to Your Wedding Party', 'Make a clear itenary for them. This is going to help diminish the long list of questions they are going to ask you during the days leading up to the wedding. You''ll thank us later. Include times to arrive for photos, and food plans for the weekend, as well as a point of contact that is not you.', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'b4cc39bd-d611-4376-8bf0-107f1e00a823', 'Blank Fun Fact', 42, NULL, NULL, NULL,
    NULL, true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'bcff6742-c9c6-49ce-835a-eccb7b50129b', 'Attire & Beauty', 41, 'Final Beauty Appointments', 'Haircut, color, facial, waxing, tan - don’t experiment with anything NEW and be sure it is all scheduled!', NULL,
    '1-3 months', false, true, '86.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '2393d18f-609c-4033-a68d-3c397b4825c8', 'Wedding Party', 40, 'Assemble Bridal Party Gifts', 'Package all of your gifts and set aside for the rehearsal dinner.', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'dee1b888-246d-4875-aad4-2f5dd2c2861f', 'stationery & paper', 39, 'Make Sure to Alphabetize Your Place Cards', 'Guests will look for their names in alphabetical order. It will help to create a smooth flow to the dinner tables. The person who will be setting these up for you will greatly thank you.', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '8e8cf32e-c1bb-4e7b-8a92-423fb83b120c', 'Reception', 38, 'Practice Your First Dance', 'Especially if you did not take lessons. Practice in your kitchen or living room to be sure you feel comfortable with each other and the song. Remember that the dress may complicate dance steps!', NULL,
    '1-3 months', false, true, '24.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '3eb0c0aa-17a4-46c1-8494-0399a97beeb8', 'Planning & Organization', 37, 'Prep a Vendor Roll Call Email', 'Prep an email to send to all of your vendors 10 days before the wedding to include the following... Final Floor Plan, Final Timeline, Final addresses of all locations, all vendor social media handles, and any other important details that you want to relay one last time. This will help minimize questions the week of the wedding.', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '455ea19f-7389-49df-bdda-fae873c6f989', 'Planning & Organization', 36, 'Confirm Timeline with All Vendors', 'You are just about a month out! Be sure to have calls scheduled with each of your vendors to review the final timeline and send along any forms that they requested.', NULL,
    '1-3 months', false, true, '90.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'ca13c17b-3cb1-4863-8cd2-aeb1ad16e87e', 'Planning & Organization', 35, 'Confirm Seating Chart with Your Venue', 'Most venues want your final count and final floor plan 2 weeks out from you''re wedding. Be sure to prepare and send this along on time!', NULL,
    '1-3 months', false, true, '43.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '60926a26-541e-47ca-aad9-4f5ee3262422', 'Legal & Admin', 34, 'Review Your Marriage License Requirements (again)', 'One month out! Make sure you have either filed for or have a plan to get your marriage license in the state you are getting married. Usually there is a waiting time for pick up, so be sure you plan accordingly!', NULL,
    '1-3 months', false, true, '64.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '04a5d235-feda-4507-9da9-811c99882e2f', 'Blank Fun Fact', 33, NULL, NULL, NULL,
    '1-3 months', true, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '3cacfac6-459d-4a3c-ab1b-3a5e7b09eebf', 'Honeymoon', 32, 'Start Packing for Your Honeymoon or Mini-Moon', 'Make a checklist so you don’t forget the essentials (or the passport).', NULL,
    'Final Month', false, true, 'Wedding Icon 63.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '72e0c2d2-45b3-4150-9e46-95295dffa391', 'Logistics & Day-Of', 31, 'Create a Wedding-Day Essentials Bag', 'Perfume, tissues, lipstick, mints, blotting papers - all the tiny lifesavers. Give to your bestie to manage for you day of!', NULL,
    'Final Month', false, false, NULL,
    'Best Blister Patches', 'https://amzn.to/49F8mGc', true, NULL,
    true, NOW()
),
(
    'bd3420de-42bc-4ade-8de9-20bd33ee323b', 'Attire & Beauty', 30, 'Steam Dresses and Suits', 'Get wrinkles out now, not morning-of chaos. Don''t keep your dress in the bag - let that baby breathe!', NULL,
    'Final Month', false, true, '114.png',
    'Non Spitting Steamer', 'https://amzn.to/4r6yG3e', true, NULL,
    true, NOW()
),
(
    'f0e43086-1649-4e17-8a18-9b9a4f587a63', 'Ceremony', 29, 'Tell Your Bridal Party to Arrive 10 Minutes Early to Your Rehearsal', 'Saying hello to all your friends and family coming in takes some time. This may be the first time you are seeing them for wedding weekend! So exciting!', NULL,
    '3-6 months', false, true, '90.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'ac90394e-b2e0-4b87-8912-3361a27aa3e2', 'Ceremony', 28, 'Print Out Your Vows', 'Even if you have vow books - have backups and also email a copy to your officiant and planner!', NULL,
    'Final Month', false, true, '64.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'aadc2cb3-623a-4096-bc6a-e5ff742bcab7', 'Guest Experience', 27, 'Put Together Welcome Bags', 'Snacks, waters, Advil, local goodies - deliver to hotels. Make sure to check with your hotels ahead of time, on the date they would like them delivered. Pro-Tip from Jamie - if you are having a welcome party, hand out all of the bags at the party instead of driving around to hotels the day before you''re wedding!', NULL,
    'Final Month', false, true, '38.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '7907536d-2f2b-48c0-8c8a-6b3dab02ae8f', 'Guest Experience', 26, 'Amenity Basket Hot Item Alert!', 'What do guests want? A cure for a hangover. We don''t have that, but a few Liquid IV''s will help make the process easier!', NULL,
    NULL, false, false, NULL,
    'Get Hydrated!', 'https://amzn.to/4r1kZ5D', false, NULL,
    true, NOW()
),
(
    'ab49a9be-c3ae-412f-b146-49cac5b481e2', 'Florals & Decor', 25, 'Confirm All Rental Quantities', 'With your RSVPs in, you can finalize your rental orders. Be sure to order 10% more of certain items in case of breakage!', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '1172052f-ef6b-4950-a56c-6dfd8ab90460', 'Catering & Bar', 24, 'Rehearsal Dinner Final Count', 'Confirm guest list and menu selections if required. Make sure you track all dietary restrictions so you can let your catering or restruant team know ahead of time.', NULL,
    'Final Month', false, true, '80.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '7ccbf423-aa60-484d-8095-d58ac11d82de', 'Planning & Organization', 23, 'Make a Weather Watch Plan', 'Start stalking the forecast - but don’t panic yet. Typically the forecast will not be correct until about 3 days out from you''re wedding day!', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '98a7ce04-e8ae-456e-aaa2-bd2d38c6808c', 'Miscellaneous', 22, 'Start Hydrating Like It’s Your Job', 'Clear skin, good energy, happy you. Even set a reminder on your phone to drink water if you are not the best at staying on top of it!', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '1fafa828-9c49-4a1c-84cc-50107415ba3b', 'Wedding Party', 21, 'Check in with Your Wedding Party', 'Any last questions? Do they know where to be and when? Consider sharing a wedding party timeline and definitely start a group text!', NULL,
    '1-3 months', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'efae0367-7f2e-4e98-9a53-51ade18eb57c', 'Miscellaneous', 20, 'Get Pumped! Your Wedding Is so Close!', '20 day out planning energy coming at you! Turn it up!', NULL,
    'Final Month', false, false, NULL,
    'Press Play!', 'https://open.spotify.com/track/6KgBpzTuTRPebChN0VTyzV?si=d813cd97aa9a42b9', false, NULL,
    true, NOW()
),
(
    '4972568f-9b6e-4608-8fe9-40230029a2e6', 'Photography & Videography', 19, 'Organize Day-Of Details for Your Photographer', 'Vow books, rings, shoes, stationary suite - put everything together so when your photo/video team arrives, it is good to go!', NULL,
    'Final Month', false, true, '42.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '0796f577-0744-4884-aacb-7e7227cd2e52', 'Miscellaneous', 18, 'Get Plenty of Sleep', 'As you get closer to you''re wedding day, the excitement is building! Be sure to get plenty of sleep - starting early helps!', NULL,
    'Final Month', false, false, NULL,
    'You Need These', 'https://amzn.to/49Kab4u', true, NULL,
    true, NOW()
),
(
    '8c050370-55e4-4a0c-980d-798e791132dc', 'Planning & Organization', 17, 'Finalize the Plan to Deliver Decor to Venue or Planner', 'Best time is 2-3 days before the wedding so that you can walk away from all of your hard work and enjoy!', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'de973836-2976-4717-8505-17934eb131f8', 'Planning & Organization', 16, 'Have a Final Check-In with Your Planner or Coordinator', 'It is always great to connect 2 weeks out with your planner one more time - final review, make sure you feel good, go into wedding week with no worries!', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '2339b863-3fcb-499d-b1d9-790c5fc252f2', 'Honeymoon', 15, 'Notify Your Bank and Credit Card Companies of Travel Plans', 'Don''t get stuck overseas with a credit card that is giving you troubles. Make sure your exchange any needed currency too.', NULL,
    'Final Month', false, true, '159.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'b59a6a34-3cae-4527-a95c-a1580257d38b', 'Honeymoon', 14, 'Pack Honeymoon Carry-On Bags', 'Pack a change of clothes or a good package of face wipes to refresh in between long flights.', NULL,
    'Final Month', false, true, 'Wedding Icon 27.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'bad1625a-b0f8-4f7d-b91d-1210a7f13296', 'budget', 13, 'Have Some Extra Cash on Hand', 'You may run into a favorite server, an exceptional delivery driver, or just want to give a favorite vendor a little bonus. Do you have an onsite tent company team member? They can often save the day at the last minute.', NULL,
    'Final Month', false, true, 'dollar_sign.png',
    NULL, NULL, true, 'tented',
    true, NOW()
),
(
    '2ddab3b1-8573-40a9-9f16-ad0581c57218', 'budget', 13, 'Have Some Extra Cash on Hand', 'You may run into a favorite server, an exceptional delivery driver, or just want to give a favorite vendor a little bonus.', NULL,
    'Final Month', false, true, 'dollar_sign.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '650bce6d-d28f-452b-a84e-a4e5a45138f8', 'Logistics & Day-Of', 12, 'Finalize Food for Getting Ready', 'Water, champagne, snacks, breakfast and/or lunch - fuel to get you through the day and ready to party! This is a great job for the groomsmen to do - pick up deliver right to you.', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '178c1662-02e0-466f-bfc3-117ea16c9afc', 'Miscellaneous', 11, 'Set an Out of Office Message at Work', 'Choose a message that truly disconnects you from work. We mean it. Don''t check your emails!', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '9c376371-1f5d-4ba8-856e-a27938b49f62', 'Miscellaneous', 10, 'Take Any Last Minute Tasks Off Your Plate', 'If there is anything left that just needs to get DONE and is easy enough to pass off, ask you''re wedding party or planner to finish your last minute to-dos. Or maybe that last DIY project is not worth it - scratch it!', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'c3cdb77d-56a9-49b5-8817-bda4eae9f8bf', 'Logistics & Day-Of', 9, 'Send Vendor Roll Call Email', 'Email all of your vendors with your final timeline and call out any last minute changes or updates. If you have a wedding planner, they will take care of this for you!', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '79060e8b-8138-4f0c-8b53-5c1dfcb5657b', 'Logistics & Day-Of', 8, 'Get Everything Together That You Will Need for Morning-Of', 'Attire, shoes, jewelry, perfume, vows, accessories. Many of these items will be captured by your photographer, so it is great to have them all packed up together and ready for day of!', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '55890086-42b0-4b3e-9434-95a503617b3d', 'Music & Entertainment', 7, 'Start Listening to Your Wedding Day Playlist Early', 'Music sets the mood. Cue the happy tears! Make sure you make a list of songs that you don''t like as well. Repeat after me style songs are sure to clear your dance floor.', NULL,
    'Final Month', false, true, 'Wedding Icon 34.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '17d172b1-99ed-4d3d-ae10-2ec5c4e48b3f', 'Miscellaneous', 6, 'Have a Relaxing Evening', 'You are officially less than a week away! If you are able to, plan a light dinner tonight with just the two of you. Encourage calm vibes, try to avoid alcohol or heavy foods - and sleep matters.', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'c226f81b-bb09-4afd-a441-a751ca24f2b9', NULL, 5, 'Check the Weather', 'Now that you are within the week of the wedding you can check weather apps as they will be more acurate. If there looks to be rain on you''re wedding day, it will be okay! Rain plans were created for this and all that matters is that you are married at the end of the day!', NULL,
    NULL, false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'eeccfa4d-0be8-4c44-a513-91a0eaa5ebf2', 'Planning & Organization', 4, 'Go Over Timeline One More Time', 'Then let it go. Your team has this!', NULL,
    'Final Month', false, true, '90.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '31ad2a26-c5ea-4666-b942-d8a305812fbe', 'Miscellaneous', 3, 'Write Letters to Each Other for Wedding Day', 'Optional, but incredibly meaningful. Assign someone from each of you''re wedding parties to deliver to each other the morning of the wedding. Bring tissues.', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '824dd38f-a083-48ad-a57a-2f7d86d69ad5', 'Miscellaneous', 2, 'Final Details!', 'Three more days! Make sure your venue has all of your decor, share any last minute updates and prepare to relax and enjoy you''re wedding weekend!', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'e5fd0da9-2c68-4754-b036-33804e8e5dcd', 'Miscellaneous', 1, 'Rehearsal Day! You Made It!', 'Bring vows, rings (or fakes), and good energy. Everyone learns their marks. And be sure to turn in early - big day tomorrow!', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '57c95574-1159-43b6-9951-94aae90e090d', 'Miscellaneous', 0, 'It’s Wedding Day! 🎉', 'You did it - the day is finally here! Take a deep breath. Enjoy every moment. Let your team handle everything. Your only job is to be fully present, marry your best friend and have the time of your life!', NULL,
    'Final Month', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '6368354c-1037-4c19-abba-dd20a1f8664b', NULL, NULL, NULL, NULL, NULL,
    NULL, false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'bb275db4-be97-4dd3-9873-05be62d03744', NULL, NULL, NULL, NULL, NULL,
    NULL, false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '25f56b06-81d7-43d2-a733-d5d89e9d1a78', 'Post Wedding Day', -1, 'Eat Leftover Cake for Breakfast. This Is Your Era!', 'If you plan to store the top tier for your year anniversary celebration, we suggest a cake storage kit!', NULL,
    'Post Wedding', false, true, 'cake 7.png',
    'Save that topper!', 'https://amzn.to/4jZNKgN', false, NULL,
    true, NOW()
),
(
    '9cb426b5-1e26-4b46-9bae-d174791b0354', 'Post Wedding Day', -2, 'Celebrate the Quiet Moment of Being Married Without an Agenda', 'You deserve it. You''ve done enough following a schedule for awhile.', NULL,
    'Post Wedding', false, true, '153.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'c93e2e87-8eb8-48c3-93a7-9a8be785d612', 'Post Wedding Day', -3, 'Put the Wedding Cards in One Safe Place (Future-You Will Thank You)', NULL, NULL,
    'Post Wedding', false, true, '51.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '887a5158-4adc-496e-bc5f-6d94aade736c', 'Post Wedding Day', -4, 'Thank a Vendor or Two If You Can - It Spreads Joy', 'This is the best way you can tell them you love them. Even better - write them an online review.', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '6466891a-6d70-47c9-94bc-a751774f7559', 'Post Wedding Day', -5, 'We Want to See Your Stunning Pictures!', 'Share 3-4 of your favorite pictures from your big day!', NULL,
    'Post Wedding', false, true, '42.png',
    'Show us your Pictures!', 'https://www.thedailyido.com/realwedding.html', false, NULL,
    true, NOW()
),
(
    '215de7f2-9ce9-4aee-befb-209ed3f6d123', 'Post Wedding Day', -6, 'Begin Your Name Change Process (if Applicable) with Social Security First', 'Pro Tip from Heather! AAA Services can help with this!', NULL,
    'Post Wedding', false, false, NULL,
    'Let AAA Help You', 'https://northeast.aaa.com/?zip=02644&devicecd=PC', false, NULL,
    true, NOW()
),
(
    'c66981a5-b5d8-4b40-89ef-e463e4b4fe08', 'Post Wedding Day', -7, 'Let the House Stay Messy Today. It’s Allowed', 'No dishes or laundry on your to do list today.', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'b0b47e67-7876-4e60-b64f-a7b88cff88e3', 'Post Wedding Day', -8, 'Plan One Tiny Thing to Look Forward to Next Week', 'Date night? Your favorite dessert after dinner? Drinks with the girls? Something fun just for you.', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '951ed9c8-8064-474d-a469-0fcf20a6809b', 'Post Wedding Day', -9, 'Talk About What Your Favorite Moment Was', 'Seeing all your friends and family? Your sweet personal vows? A drunk Uncle on the Dance Floor? We know there is more than just one favorite of the day.', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'dd65301d-5edc-4551-9071-c575099c9cb3', 'Post Wedding Day', -10, 'Eat a Real Meal Together Before Answering a Single Text', 'After wedding day, it''s so easy to get stuck in a "non-routine" daily stride. Sit down and have a nice dinner together to get back into the swing of things.', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'ff1b54af-68f3-4ded-98fd-0d61d6159ec2', 'Post Wedding Day', -11, 'Say “We Did It” Out Loud - It Makes It Feel Real', 'It might all still be a blurr, but your definitely married now! Hooray!', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '1746ee70-b7f5-43f4-8385-e61a7f608e1e', 'Post Wedding Day', -12, 'Give Yourselves Grace Post Wedding - Emotions Can Be Big', 'It''s okay to still feel all the feels of the big day. It just means you loved every minute of it.', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '2dc375d9-6de5-4859-b91a-f94fe48bacf2', 'Post Wedding Day', -13, 'Confirm Your Wedding Photos Are Scheduled for Delivery and Know Timelines', 'Follow up with your photo and video team. They may send some sneak peaks, and set an expectation for a delivery time of your final gallery.', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '45f96fde-a07d-4c4b-a83e-dfb13e8154e9', 'Post Wedding Day', -14, 'Clean and Store Wedding Shoes, Accessories, and Jewelry Properly', 'It''s so easy to overlook this detail. You''ll want to keep them nice, don''t skip this one.', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'bd7f8585-3248-4080-bbeb-b62d098f60ef', 'Post Wedding Day', -15, 'Have a Date Night', 'Enjoy being Married. Every moment of it is amazing.', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '8543370c-6d56-4e28-a469-3890b8bfe64a', 'Post Wedding Day', -16, 'Confirm Final Vendor Invoices Are Fully Paid and Closed', 'Although most vendors will require final payments before the wedding, you want to make sure nothing was missed!', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '3e9b402c-a7a0-4369-a581-312f957ee5f9', 'Post Wedding Day', -17, 'Schedule Routine Appointments You Postponed During Planning', 'Dentist the day before you''re wedding? No Thanks. We would have rescheduled too.', NULL,
    'Post Wedding', false, true, '90.png',
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'ba299956-75a7-443f-8095-44efa3d0c8af', 'Post Wedding Day', -18, 'Decide How You’ll Handle Social Media Posting of Wedding Photos', 'Set an expectation with your spouse on what and where you would like to share. It''s okay to keep some things private just for you.', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '93bb8a07-adfa-45a9-ba8f-6664fd62121e', 'Post Wedding Day', -19, 'Time to Preserve Your Dress', 'Research local cleaning services, and ask about timelines.', NULL,
    'Post Wedding', false, true, '90.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'aad97227-0db6-43e5-b902-4c91ceee6aa9', 'Post Wedding Day', -20, 'Update Workplace Records', 'Contact your HR department so they can update all your contact information and company directory info - think HR Systems, Email Signatures, Benefits Portals, etc.', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'da43147a-2ebc-4c39-989d-eaa2f2c6fe78', 'Post Wedding Day', -21, 'Choose One Favorite Photo to Print and Frame Right Away', 'There nothing like reliving the joy of the day every time you walk into your home. Heather''s favorite place to print is called Smallwood Home. Your photos really become a part of your home.', NULL,
    'Post Wedding', false, true, '42.png',
    'Heather Loves These!', 'https://www.smallwoodhome.com/', false, NULL,
    true, NOW()
),
(
    '616612fd-0a56-45f0-a38d-a2ed7416d9b5', 'Post Wedding Day', -22, 'Get Multiple Certified Copies of Your Marriage Certificate', 'This is going to be very helpful when it comes time to change your name and bank accounts. Copies need to be real, not photocopies.', NULL,
    'Post Wedding', false, true, '64.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    'a530b273-797f-472f-9cc8-a0835cfa8901', 'Post Wedding Day', -23, 'Update Your Driver’s License or Id After Your Name Change Is Approved', 'Keep any printed forms with you until you get the new one in the mail. Better safe than sorry.', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '9722a48a-8f77-4932-8a3d-bdeb95eb5072', 'Post Wedding Day', -24, 'Update Beneficiaries on Life Insurance and Retirement Accounts', 'This one is important! You want to make sure everything is accurate', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '153331f6-7167-4fe2-b58e-94da903b6480', 'Post Wedding Day', -25, 'Combine or Organize Shared Finances and Set a Household Budget', 'Woah. This is a big one. Might need a glass of wine.', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    'df1331de-9cba-4ff3-9a58-4c82ec507cf0', 'Post Wedding Day', -26, 'Send Thank-You Notes (Ideally Within 1–2 Months)', 'Guests look forward to getting a note in the mail. Don''t forget your vendors. They love you as much as your guests do!', NULL,
    'Post Wedding', false, true, '51.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '9a8ab3cf-16f2-4e8d-8cb9-8541d9311c69', 'Post Wedding Day', -27, 'Store Your Marriage License in a Safe, Permanent Place', 'You are going to need this more than you think in your future. Save yourself the trouble of having to go back to town hall for a copy.', NULL,
    'Post Wedding', false, true, '64.png',
    NULL, NULL, true, NULL,
    true, NOW()
),
(
    '6fc3396a-187b-47ba-98bb-f89f2169f61e', 'Post Wedding Day', -28, 'Still Reliving Your Day Through Photos?', 'Send a few our way so we can see all your hard work come to life!', NULL,
    'Post Wedding', false, false, NULL,
    'We want to see!', 'https://www.thedailyido.com/realwedding.html', false, NULL,
    true, NOW()
),
(
    '4e78144d-b26d-4a9c-ab0e-606976f7e294', 'Post Wedding Day', -29, 'Laugh About the One Thing That Went Wrong—it’s Already Your Favorite Story', 'Pro Tip from Heather - One thing will go wrong on you''re wedding day no matter what. It''s okay, it always happens. It will be funny someday.', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
),
(
    '5c29481e-74cc-43b0-b0ea-f20d4c60ae39', 'Post Wedding Day', -30, 'Remember: The Wedding Ended, but the Best Part Just Began', 'CONGRATULATIONS. We love you, thank you for taking this ride with us. We wish you the most happy future together', NULL,
    'Post Wedding', false, false, NULL,
    NULL, NULL, false, NULL,
    true, NOW()
);