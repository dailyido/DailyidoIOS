-- Fun Tips Import for Supabase
-- Generated: 2026-01-22T13:28:33.133689
-- Total rows: 124

-- First, clear existing data
DELETE FROM fun_tips;

-- Insert all fun tips
INSERT INTO fun_tips (
    id, title, tip_text, category, priority,
    has_illustration, illustration_url,
    affiliate_button_text, affiliate_url,
    is_active, created_at
) VALUES
(
    'd5b6f2fe-1c07-46ca-a2d3-45e3739e3729', 'Appreciate the Small Things', 'Take 5 minutes to notice and express gratitude for the small things your partner does daily.', 'Appreciate the Small Things', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '6c095c49-eb0a-4ac7-9c30-de08acea4a4f', 'Art Museum Date', 'Visit an art museum together. Wander slowly, discuss what you see, pretend to be art critics.', 'Art Museum Date', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'e2bb2aa6-499b-4ded-a619-7a3719573cdd', 'At-Home Spa Night', 'Draw a bath, light some candles, put on face masks. You both deserve a little pampering tonight.', 'At-Home Spa Night', NULL,
    true, '193.png',
    NULL, NULL,
    true, NOW()
),
(
    '920d388e-9384-4a12-a5a9-95d86d8a06c8', 'Breakfast in Bed', 'Wake up early and make breakfast in bed for your partner. Bonus points for fresh flowers.', 'Breakfast in Bed', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '4c45f0e0-bc10-4bb1-bdd7-e614baf6c387', 'Browse Real Wedding Galleries', 'Spend 20 minutes browsing real wedding galleries together. Save any details that catch your eye to your shared Pinterest board.', 'Browse Real Wedding Galleries', 1,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '9c28699b-ee58-44a2-9896-915e1a21f195', 'Call a Married Friend', 'Reach out to a married friend or couple you admire. Ask them what they wish they''d known before their wedding.', 'Call a Married Friend', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '57242d94-d8a7-4227-bb72-5c57db3bc9f3', 'Comedy Show Date', 'Go see live stand-up comedy together. Laughing together strengthens your bond.', 'Comedy Show Date', NULL,
    true, '34.png',
    NULL, NULL,
    true, NOW()
),
(
    'f5c31968-a95d-40f6-a287-28c790546acf', 'Compliment Challenge', 'Take turns giving each other genuine compliments for 5 minutes straight. Harder than it sounds!', 'Compliment Challenge', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'ec7b84e7-f9c3-41e2-8f71-bcf1dea3296f', 'Create a Bucket List', 'Start a couples bucket list of things you want to do together in your lifetime. Dream big and add to it regularly!', 'Create a Bucket List', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '116c7b5e-f6d6-4f37-a8b1-fceb9739ed22', 'Create a Couple''s Playlist', 'Build a playlist together of songs that define your relationship. Include your first date song, road trip favorites, and songs that remind you of each other.', 'Create a Couple''s Playlist', 1,
    true, '32.png',
    NULL, NULL,
    true, NOW()
),
(
    '7ee81635-1fc8-4b5a-8945-d8bee8b1c989', 'Create a Time Capsule', 'Start collecting items for a wedding time capsule: photos, notes, ticket stubs. Open it on your 10th anniversary.', 'Create a Time Capsule', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'ea981a89-dcbd-4f4f-859b-050b9df71fdb', 'Daily I Do Planning Poem for You', 'They said, “Let’s plan a wedding-easy, right?” Then came the charts, the calls, the napkins in twelve shades of white. Between cake tastings, budgets, and opinions strong and loud, Love stayed front and center, steady, patient, and proud. Every checklist moment led them perfectly here today, Proof that all that planning paved a joyful, forever way.', 'Daily I Do Planning Poem for You', 1,
    true, '66.png',
    NULL, NULL,
    true, NOW()
),
(
    'bc32dc1f-d2ca-4f00-98f6-915a3e9479c3', 'Daily I Do Planning Poem for You', 'They started planning full of joy, then spreadsheets took the lead, With budgets, timelines, and opinions they did not request or need. The playlist sparked debate, the seating chart caused a fight, And someone’s Uncle clearly planned to drink way too much that night. But through the chaos, laughs, and champagne poured with cheer, They made it to “I do"and that’s the moment that matters here.', 'Daily I Do Planning Poem for You', 1,
    true, '78.png',
    NULL, NULL,
    true, NOW()
),
(
    '3a7f20ff-fc85-4f51-9578-dc0f74fc711a', 'Daily I Do Planning Poem for You', 'You''ve planned every detail, from flowers to vows, Pinned charts on the fridge with stress on your brows. The cake showed up sideways, the DJ played a wrong song, Uncle Mike gave a toast that lasted way too long. But we laughed through the chaos, danced anyways, Because love showed up perfectly, even that day.', 'Daily I Do Planning Poem for You', 1,
    true, '5.png',
    NULL, NULL,
    true, NOW()
),
(
    'b4089785-0862-4725-9a95-aa739d1f0021', 'Daily I Do Planning Poem for You', 'They started planning full of joy… then panic entered stage right, With budgets, timelines, and contracts keeping them up at night. The to-do list grew faster than the guest list ever could, Until this app stepped in with daily tips saying, “You''re doing good.” One reminder at a day at a time, the stress began to dip, Because happily ever after pairs nicely with daily wedding planning tips.', 'Daily I Do Planning Poem for You', 1,
    true, '185.png',
    NULL, NULL,
    true, NOW()
),
(
    'b77c9b52-0980-43a2-9cfa-ba0545604d7a', 'Daily I Do Signature Sip', 'Blackberry Sage Smash (But give it your own fun name!)\n\n2 oz bourbon\n ½ oz lemon juice\n ½ oz simple syrup\n Blackberries & sage\n\n Instructions:\n Muddle berries and sage, shake, strain over ice.', 'Daily I Do Signature Sip', NULL,
    false, NULL,
    'Shake it up!', 'https://amzn.to/4jRJY8T',
    true, NOW()
),
(
    '17d89f83-c705-436e-be94-68ac16b9a0d3', 'Daily I Do Signature Sip', 'Champagne Paloma\n\n Fun and Bubbly Ingredients\n 1½ oz tequila\n 1 oz grapefruit juice\n Champagne to top\n\n Shake tequila and juice, strain\ntop with champagne.', 'Daily I Do Signature Sip', 1,
    true, 'Wedding Icon 29.png',
    NULL, NULL,
    true, NOW()
),
(
    '58e2c41f-38bf-48a2-bd22-7cd915a31254', 'Daily I Do Signature Sip', 'Lavender Love Spritz\n Perfect for spring or garden weddings\n\nIngredients:\n 2 oz prosecco\n 1 oz lavender syrup\n 1 oz vodka\n Splash of soda water\n\n Instructions:\n Build in a wine glass over ice\n Stir gently. Garnish with lavender or lemon.', 'Daily I Do Signature Sip', NULL,
    true, 'Wedding Icon 115.png',
    'Buy the Syrup', 'https://amzn.to/4sL24h3',
    true, NOW()
),
(
    '8d118926-1ee6-4335-8fb5-252e0fad5d2c', 'Daily I Do Signature Sip', 'The Old Fashioned I Do\n Timeless and Classic\n\n Ingredients:\n 2 oz bourbon\n ¼ oz simple syrup\n 2 dashes bitters\n\n Instructions\n Stir with ice and strain over a large cube\n Garnish with orange peel and cherry', 'Daily I Do Signature Sip', 1,
    true, 'Wedding Icon 68.png',
    'The Best Cherries!', 'https://amzn.to/3NTa9A1',
    true, NOW()
),
(
    '35c70f2f-0b72-43e1-9f2c-646b975fb940', 'Daily I Do Signature Sip', 'Blueberry Bliss Lemonade\nSomething Blue!\n\n Ingredients (per drink)\n 2 oz vodka (or gin)\n 3 oz fresh lemonade\n 1 oz fresh muddled blueberries\n Splash of club soda (optional)\n\n Garnish:\n fresh blueberries & lemon wheel\n Instructions:\n Shake vodka (or gin), lemonade, and blueberrys\n Strain into a glass over fresh ice\n Top with club soda if desired and garnish\n\nMake it a Mocktail!\n Replace the alcohol with extra lemonade or sparkling water.', 'Daily I Do Signature Sip', 1,
    true, 'Wedding Icon 68.png',
    NULL, NULL,
    true, NOW()
),
(
    '78a05118-ab72-40c1-a043-446c800ec01a', 'Daily I Do Signature Sip', 'The Peachy Keen:\n Light and celebratory\n\n Ingredients:\n 2 oz peach purée\n 4 oz prosecco\n\n Instructions:\n Pour peach purée into a flute\nTop with prosecco\n Stir gently', 'Daily I Do Signature Sip', NULL,
    true, 'Wedding Icon 29.png',
    NULL, NULL,
    true, NOW()
),
(
    '3e880b51-5308-4957-964e-a8bdd311a5f2', 'Daily I Do Discussion', 'Trust vendors who say, “Don’t worry, I''ve seen worse.” We sincerely mean it. We have always seen worse and nothing will ever surprise us. We are prepared for it all.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'c849eaca-5685-4082-a457-87f0f587b387', 'Daily I Do Discussion', 'You don''t need 47 signature cocktails, just pick one or two and commit. Guests will most likely only have 1-2 during cocktail hour and then switch to their drink of choice for the remainder of the evening. We certainly think you should taste them all throughout planning!', 'Daily I Do Discussion', 1,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'e494d57e-0afe-4eb2-b943-615ed0fe2ce3', 'Daily I Do Discussion', 'You don''t need to explain your choices to anyone who isn''t paying. Everybody will love to offer up their thoughts and advice, even if they are offering up their wallet. Do what you want, it''s your wedding.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '78a6eb6c-61a0-4ef5-9485-08fe46e9780f', 'Daily I Do Discussion', 'Your flower girl is going to do whatever she wants, and that''s okay. She may practice with a smile on her face, and then walk the aisle with tears. It happens, the photos are worth it. The stress is not!', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '5c6e4a54-c352-4f37-b773-18bd5fa56d13', 'Daily I Do Discussion', 'It’s okay to say “I don''t care” about some things. Time time to plan and thing through items that really mean something to you, like your vows or color schemes. It''s okay if you don''t care what shape the wine glasses are.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'dbbe3cb3-0d89-48aa-86c1-3df4251c0281', 'Daily I Do Discussion', 'The day will go fast, no matter what you planned. People are going to say "wait until you see how fast the day goes by," and they are right. Plan a few moments for a breather and to actually enjoy what''s happening around you.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '4ebc884c-2164-4fca-b05c-6fff579528d5', 'Daily I Do Discussion', 'The best photos happen when you stop posing. It''s okay to take the staple photos you plan to have printed in an album, but it''s also okay to tell your photographer to focus capturing the candid moments. Those are usually the ones that make your heart the most happy.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '08d38e66-5b1f-4560-b7d1-0faa0f73b440', 'Daily I Do Discussion', 'You are allowed to change your mind - this is not a tattoo. If you have a nightmare about your first dance song, just change it. Nobody will hold it against you.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '6ba18a80-f996-4d1c-bbc6-881c26190abd', 'Daily I Do Discussion', 'Are you planning a bachelor or bachelorette party? Keep in mind your wedding party, their budgets and their calendars. Don''t ask too much of them, but definitely throw a fun weekend celebrating each of you!', 'Daily I Do Discussion', 1,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'f56f24be-63fb-44e0-ad1f-d2eac90e6c7e', 'Daily I Do Discussion', 'If you love it but your mom hates it, flip a coin (just kidding… mostly). It''s okay to kindly explain why you care about something deeply, even if they don''t agree. In the end, all your family wants is for you to be happy.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'ace3d940-24f6-4ac6-8e76-9caaf4abd72f', 'Daily I Do Discussion', 'If the seating chart causes tears, step away and eat a snack immediately. It''s so hard to pick where to place all your guests when there are a lot of family dynamics. It''s okay to place guests where you think is best and then don''t ask for other opinions. It just a 2 hour dinner, then you''ll see everybody on the dancefloor.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '39abe1a8-83da-4990-ad73-b2baa893278d', 'Daily I Do Discussion', 'If it works on Pinterest and in real life, you''ve struck gold. Don''t forget so many photos are staged photo shoots. Try to find the ones from real weddings with ideas that are possible. You''ll be happier and so won''t your set up team.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '16375b80-1219-4807-a3eb-90e6f35ff3d8', 'Daily I Do Wedding IQ', 'The bouquet toss tradition dates back to 14th century England, when guests would try to rip pieces of the bride''s dress for good luck. The bouquet became a less destructive alternative!', 'Daily I Do Wedding IQ', NULL,
    true, 'Flower Bouquet 1.png',
    NULL, NULL,
    true, NOW()
),
(
    'd8f11ec9-af5a-4649-9c4e-bc66907933b0', 'Daily I Do Wedding IQ', 'The average U.S. wedding costs around $30,000. But averages are skewed by big-budget weddings - the median is closer to $20,000.', 'Daily I Do Wedding IQ', NULL,
    true, 'dollar_sign.png',
    NULL, NULL,
    true, NOW()
),
(
    'b620f761-a50c-45a3-bd83-5540c293462e', 'Daily I Do Wedding IQ', 'Queen Victoria started the white wedding dress trend in 1840. Before that, brides simply wore their best dress, regardless of color.', 'Daily I Do Wedding IQ', NULL,
    true, 'Dress 1.png',
    NULL, NULL,
    true, NOW()
),
(
    'f41a1ff9-800b-49f3-9183-9527b2b9fe1c', 'Daily I Do Wedding IQ', 'The ring finger tradition comes from ancient Romans who believed the ''vena amoris'' (vein of love) ran directly from that finger to the heart.', 'Daily I Do Wedding IQ', NULL,
    true, 'Rings 1.png',
    NULL, NULL,
    true, NOW()
),
(
    '3240fa75-160f-49c1-bcf6-4e9dc7c1a549', 'Daily I Do Wedding IQ', 'The ''best man'' tradition comes from ancient Germanic Goths, when a groom needed his strongest friend to help him capture his bride. Times have changed!', 'Daily I Do Wedding IQ', NULL,
    true, '139.png',
    NULL, NULL,
    true, NOW()
),
(
    '91623e45-e6ea-4b40-b957-882d4b38195b', 'Daily I Do Wedding IQ', 'The ''something blue'' tradition represents purity, love, and fidelity in many cultures. It dates back to ancient Rome.', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'f9b13c1e-1066-4c4c-94b4-d84c4671ec2b', 'Daily I Do Wedding IQ', 'Flower girls originally carried garlic and herbs, not petals - believed to ward off evil spirits and bad luck!', 'Daily I Do Wedding IQ', NULL,
    true, 'Flower 3.png',
    NULL, NULL,
    true, NOW()
),
(
    '25c34e15-aa9e-45df-8239-5108db66719c', 'Daily I Do Wedding IQ', 'The tradition of saving the top tier of your wedding cake comes from a time when couples were expected to have their first baby within a year.', 'Daily I Do Wedding IQ', NULL,
    true, 'Cake 1.png',
    NULL, NULL,
    true, NOW()
),
(
    'c27ca0e1-c595-4ed8-b13b-d1e355f84625', 'Daily I Do Wedding IQ', 'Nearly 50% of couples go over budget, usually due to “small upgrades” that add up fast. Be sure to plan a budget and stick to it!', 'Daily I Do Wedding IQ', NULL,
    true, 'Champagne Bottle 1 .png',
    NULL, NULL,
    true, NOW()
),
(
    '49ab3bce-4f87-4044-b4a6-993a166bd98f', 'Daily I Do Wedding IQ', 'Veils were originally worn to hide the bride from evil spirits or to prevent the groom from seeing her face in arranged marriages!', 'Daily I Do Wedding IQ', NULL,
    true, 'Veil.png',
    NULL, NULL,
    true, NOW()
),
(
    '45af4fde-6289-4a9c-8a07-7d6bc463df14', 'Daily I Do Wedding IQ', 'Groomsmen originally dressed identically to the groom to confuse evil spirits and protect the couple.', 'Daily I Do Wedding IQ', NULL,
    true, 'Groom Suit 1.png',
    NULL, NULL,
    true, NOW()
),
(
    '513bee38-848a-4358-a6e8-f742e49f689b', 'Daily I Do Wedding IQ', 'Clinking glasses originated in medieval times as a way to prove drinks weren''t poisoned - the liquids would slosh between cups.', 'Daily I Do Wedding IQ', NULL,
    true, 'Wine Glasses .png',
    NULL, NULL,
    true, NOW()
),
(
    '09738fea-7c3c-4fa4-a254-544aa6a6d672', 'Daily I Do Wedding IQ', 'Carrying the bride over the threshold comes from the belief that evil spirits lived in the floor and could enter through her feet.', 'Daily I Do Wedding IQ', NULL,
    true, '124.png',
    NULL, NULL,
    true, NOW()
),
(
    '5efc7f40-63cc-44f1-a5dc-9d3ec7f3d020', 'Daily I Do Wedding IQ', 'June weddings became popular because people took their annual baths in May. June brides still smelled relatively fresh!', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '70113b97-9cc2-4df3-b5cb-55fd934e4ddf', 'Daily I Do Wedding IQ', 'In some cultures, rain on your wedding day is considered good luck and you will have even better luck with a solid rain plan!', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'c8031c9d-8ead-46f6-8e46-2e3aea15ba46', 'Daily I Do Wedding IQ', 'Princess Diana''s engagement ring (now Kate Middleton''s) broke tradition by using a sapphire instead of a diamond.', 'Daily I Do Wedding IQ', NULL,
    true, 'Ring 1.png',
    NULL, NULL,
    true, NOW()
),
(
    '9ac41ad7-0bd1-4a87-bf9c-4bf1802ab357', 'Daily I Do Wedding IQ', 'Guests sitting on the bride''s side vs. groom''s side comes from a time when families needed to be ready to defend their side in case of objections!', 'Daily I Do Wedding IQ', NULL,
    true, '37.png',
    NULL, NULL,
    true, NOW()
),
(
    '56d1dda5-c2b2-4164-9c3b-4fe2cd4fb870', 'Daily I Do Wedding IQ', 'The average engagement in the U.S. is 15 months. Couples who date for 3+ years before engagement have lower divorce rates.', 'Daily I Do Wedding IQ', NULL,
    true, '96.png',
    NULL, NULL,
    true, NOW()
),
(
    '3fa3573b-5fbc-4e28-b672-b5f877c3dde8', 'Daily I Do Wedding IQ', 'The bride cuts the cake first because, historically, it symbolized her transition to domestic duties. Today it''s just photo-op tradition!', 'Daily I Do Wedding IQ', NULL,
    true, 'Cake 3.png',
    NULL, NULL,
    true, NOW()
),
(
    '60cc0815-e959-4161-9398-9ee93dd040c0', 'Daily I Do Wedding IQ', 'Fathers ''giving away'' the bride comes from when daughters were property. Modern couples often modify this tradition.', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'c117c81e-775c-482a-a8f5-e7be3f4611be', 'Daily I Do Wedding IQ', 'Throwing rice or confetti represents wishes for fertility and prosperity. Some venues now ban rice to protect birds.', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'b9a2b407-90bc-4c95-a992-f764d9339495', 'Daily I Do Wedding IQ', 'Engagement photos became popular in the 1990s as a way for couples to get comfortable in front of the camera before the big day.', 'Daily I Do Wedding IQ', NULL,
    true, 'Photos.png',
    NULL, NULL,
    true, NOW()
),
(
    'fe24f9bf-5dd7-4304-98c2-82356be31458', 'Daily I Do Wedding IQ', 'The average wedding party has 5 bridesmaids and 5 groomsmen. But there are no rules - do what feels right!', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'f5eba678-c4c8-4328-b334-30d2c26a4d72', 'Daily I Do Wedding IQ', 'The unity candle ceremony, where two flames become one, only became popular in the 1970s - it''s not an ancient tradition!', 'Daily I Do Wedding IQ', NULL,
    true, 'Candlestick 2.png',
    NULL, NULL,
    true, NOW()
),
(
    '701dbc84-37de-47e7-a963-16c6bac99177', 'Daily I Do Wedding IQ', 'The phrase ''mind your Ps and Qs'' may have originated from bartenders tracking pints and quarts on a tab!', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'f218ba21-9463-4e3a-8359-d619197dbf88', 'Daily I Do Wedding IQ', 'Decorating the getaway car started as a way to announce the marriage to the community before modern communication.', 'Daily I Do Wedding IQ', NULL,
    true, 'Car1.png',
    NULL, NULL,
    true, NOW()
),
(
    'fedb8e09-311b-40c4-963a-48a3fe6088a5', 'Daily I Do Wedding IQ', 'The average wedding guest spends $100–$150 on a gift. Lucky you!', 'Daily I Do Wedding IQ', NULL,
    true, '170.png',
    NULL, NULL,
    true, NOW()
),
(
    'fe140898-1de6-4ef1-8e20-9e29c9f38816', 'Daily I Do Wedding IQ', 'Wedding registries date back to 1924, when a Chicago department store introduced them to help guests avoid duplicate gifts. Make sure you have a registry for your guests to shop!', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'acfe58cd-ee25-46ef-93e3-6354225ef567', 'Daily I Do Wedding IQ', 'Ancient Greeks believed weddings should happen during a full moon for prosperity.', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'e086c326-f7e7-470c-bc75-9ac951275989', 'Daily I Do Wedding IQ', 'The Word "Wedding" Comes From an Old English word meaning "to pledge."', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '1701da7d-db31-4640-82f0-3d16a13a34bd', 'Daily I Do Wedding IQ', 'At the end of the day, guests remember how the wedding felt, more than how it looked', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '3a0a2caa-d5d0-4528-a85a-ede25cbf9a3e', 'Daily I Do Wedding IQ', 'Did you know? Indian weddings often last multiple days, not just one. They also often have over 500 guests... that''s a lot of invitations to address!', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '9f8fda35-bdb9-4fb7-9c61-a30ef30fa427', 'Daily I Do Wedding IQ', 'In Ancient Rome, brides wore flame-colored veils to symbolize warmth and protection - bold veils have always been a power move! Have you purchased yours yet?', 'Daily I Do Wedding IQ', NULL,
    true, '117.png',
    NULL, NULL,
    true, NOW()
),
(
    'b9ebf2cb-22b2-4b4c-beb1-5e2a227a63e2', 'Daily I Do Wedding IQ', 'Did you know that even Princess Kate Middleton participated in the fun wedding tradition of Something Borrowed, Something Blue, Something Old and Something New? Kate honored this wedding tradition with: Old: Carrickmacross lace in her gown New: Bespoke earrings from her parents Borrowed: The Cartier Halo tiara from Queen Elizabeth II Blue: A discreet bit of blue lace sewn into her dress - just like Princess Diana did.', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'f468cc75-e6c7-4589-a799-0dab1c9eaf33', 'Daily I Do Wedding IQ', 'Wedding cakes were once broken over the bride’s head for good luck (we''re glad that tradition evolved!)', 'Daily I Do Wedding IQ', NULL,
    true, '67.png',
    NULL, NULL,
    true, NOW()
),
(
    '00a594f8-9a29-44eb-9ef4-545ccb3826f4', 'Daily I Do Wedding IQ', 'Did you know? During Medieval times it was thought to eat honey for happiness? Newlyweds drank honey wine (mead) for a month, inspiring the term honeymoon.', 'Daily I Do Wedding IQ', NULL,
    true, '72.png',
    NULL, NULL,
    true, NOW()
),
(
    '0d5e668a-e376-451a-979a-d97a56341699', 'Daily I Do Wedding IQ', 'Before diamonds became popular, wedding rings were often made of iron to symbolize strength and permanence.', 'Daily I Do Wedding IQ', NULL,
    true, '94.png',
    NULL, NULL,
    true, NOW()
),
(
    '879a6ada-a80b-4696-b6f5-96264ca92c94', 'Daily I Do Wedding IQ', 'Matching wedding parties became popular to show wealth and unity, not just aesthetic coordination.', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '95bf51be-bed0-4aca-a3f7-9ec8c16c1638', 'Daily I Do Wedding IQ', 'In medieval England, bridesmaids had to help fight off suitors who tried to steal the bride. Sounds like a good time!', 'Daily I Do Wedding IQ', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '97217aa4-c4fd-4fa4-9169-6decd538e9f0', 'Daily I Do Wedding IQ', 'A De Beers'' 1947 advertising campaign, featuring copywriter Frances Gerety'' iconic slogan, "A Diamond Is Forever," was pivotal in making diamond engagement rings mainstream and an expected symbol of eternal love and marriage in the U.S., transforming them from a luxury item for the wealthy to a standard for the middle class.', 'Daily I Do Wedding IQ', NULL,
    true, '96.png',
    NULL, NULL,
    true, NOW()
),
(
    'f31635e6-f92c-4600-8bb1-bef3c797cadb', 'Deep Breathing Together', 'Sit in a cozy spot, hold hands and spend 5 minutes doing deep breathing exercises together. It sounds silly, but it''s incredibly calming.', 'Deep Breathing Together', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'fa80aef2-32d3-446b-84e1-9f93f753a7e4', 'Start a Shared Photo Album', 'You will have lots of photos throughout the planning process. Start a shared album together so you can keep them all in one place. Invite others along the way.', 'Start a Shared Photo Album', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '1f8e3e4a-61a2-43ec-ac99-1a3d4ebec45a', 'Disconnect to Connect', 'Leave your phones in another room for the entire evening. Be fully present with each other.', 'Disconnect to Connect', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '5f3b7234-e485-4903-a56c-bbc47715ae47', 'Daily I Do Discussion', 'What does growing old together look like to you? Talk about the life you want to build long-term.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '7c6d0add-5334-40e3-9180-406cf874dd01', 'Daily I Do Discussion', 'Where do you each see your careers in 5 years? How can you support each other''s professional dreams?', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '9b14f886-48bc-473b-b9b7-5512905ae4dc', 'Daily I Do Discussion', 'If you want kids, talk about your ideal timeline. If you don''t, make sure you''re aligned. This is a big one.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '07b83a57-2994-4d60-9723-ae12a1dbc2af', 'Daily I Do Discussion', 'How do you both handle conflict? What works well? What could be better? Having this conversation now will help later.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'ceb4be83-9d70-4631-af7a-2168023ea830', 'Daily I Do Discussion', 'What family traditions do you each want to bring into your marriage? Which ones do you want to create together?', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'ceced1af-0129-4c74-a8a1-67491cbeb744', 'Daily I Do Discussion', 'How will you split holidays between families? This conversation is better to have now than the week before Thanksgiving!', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '13b3a360-3ae0-4072-b3c7-8981940b455c', 'Daily I Do Discussion', 'Money is the #1 topic couples argue about. Take time today to discuss your financial goals, habits, and philosophies. Also schedule monthly money meetings so you can stay on the same page.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '9bd218e6-4241-4a46-851a-7a66727a35a6', 'Daily I Do Discussion', 'What are your small pet peeves? Dirty dishes in the sink? Toilet seat left up? Knowing these ahead of living together forever helps avoid silly arguments.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '0324d1a5-4104-4db9-a50f-78c0f49b3acf', 'Daily I Do Discussion', 'Are you a dog family or cat family? Both? Neither? If you don''t have pets, talk about future pet plans.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '19c1e8ce-22ac-498c-9264-1a3ad2f8b479', 'Daily I Do Discussion', 'What are you most excited about for life after the wedding? Talk about your goals for your first year of marriage.', 'Daily I Do Discussion', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '08cb3a66-8286-4eed-8964-1c5906bc5bc7', 'Explore a New Neighborhood', 'Pick a neighborhood in your city you''ve never explored. Wander, find a coffee shop, pretend you''re tourists.', 'Explore a New Neighborhood', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '62f259db-dff9-44ea-9d13-19452acda463', 'Have a Fancy Dinner at Home', 'Cook an elaborate meal together, set the table nicely, light candles, dress up. Restaurant vibes, home comfort.', 'Have a Fancy Dinner at Home', NULL,
    true, 'Dinner plate.png',
    NULL, NULL,
    true, NOW()
),
(
    '1c10d713-96f8-4833-b634-76eaef22707e', 'Five-Minute Meditation', 'Wedding planning can be overwhelming! Download a meditation app and do a 5-minute guided meditation together and add this into your daily or weekly routine.', 'Five-Minute Meditation', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'c0ec2986-4c5a-44dc-8fe7-e359fd804e8b', 'Game Night for Two', 'Break out the board games or card games. Keep score, get competitive, have fun.', 'Game Night for Two', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'c779b182-b739-4e13-a776-08222bbaf46a', 'Ice Cream Date', 'Simple but classic: go out for ice cream together. Sometimes the smallest dates are the sweetest.', 'Ice Cream Date', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'c5f97ed6-5e8b-4aee-b967-dd748e769137', 'Journal Together', 'Buy two identical journals. Write in them on the same nights, then swap and read what the other wrote.', 'Journal Together', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '39bed874-5798-422d-92c4-5131557cf60a', 'Live Music Date', 'Find live music playing somewhere in your city tonight. Doesn''t have to be fancy - a bar band counts.', 'Live Music Date', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '1ff67e21-094a-420c-ae3a-9c6186ce92cf', 'Take a Drive Down Memory Lane', 'Drive by the place you first met, first kissed, or had your first date. Relive the memories together.', 'Take a Drive Down Memory Lane', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'aec5b55e-fed3-4089-8369-ea90528b572b', 'Morning Gratitude', 'Before getting out of bed, share one thing you appreciate about each other. Start the day right and totally in love.', 'Morning Gratitude', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '6a86bb23-01a0-4672-aed2-8ab0e3d1fc42', 'Movie Night In', 'Pick a movie neither of you has seen. Make popcorn, snuggle up, and enjoy the night.', 'Movie Night In', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '05aca091-8a29-4158-b40b-60955b593c08', 'Plan a Picnic', 'Pack a simple picnic and head to a park. Bring wine or lemonade, cheese, fruit, and nothing to do but enjoy each other''s company.', 'Plan a Picnic', NULL,
    true, 'Cheese.png',
    NULL, NULL,
    true, NOW()
),
(
    '9a8c2d73-243d-400b-a2bd-f03a7c3f743c', 'Plan a Staycation', 'Book a weekend staycation at a nice hotel in your own city. Practice being pampered before the honeymoon!', 'Plan a Staycation', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '6de61f00-5091-456a-87ee-4af1b95bd2b6', 'Plan a Surprise Date', 'Take turns planning surprise dates for each other. The only rule: don''t reveal where you''re going until you arrive!', 'Plan a Surprise Date', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'f1296d35-d4c4-4f28-ad6b-65f54f2b2cf6', 'Plan Your First Anniversary', 'It''s never too early to dream! Where do you want to spend your first wedding anniversary?', 'Plan Your First Anniversary', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'a23f0aa9-c61a-4e40-8721-933ab95536b7', 'Practice Saying ''I Do''', 'Stand face to face, hold hands, and practice saying your vows to each other. Even if you use the traditional ones, it''s powerful. And don''t forget to practice the kiss!', 'Practice Saying ''I Do''', 1,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '91c6891f-9429-46d3-87a1-48ec77cc1c6f', 'Practice Your Vows', 'If you''re writing personal vows, start a notes file on your phone. Jot down moments and feelings as they happen. You''ll thank yourself later!', 'Practice Your Vows', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'f27236dc-6aa6-4be8-b2af-2a36181bd5e5', 'Puzzle Night', 'Start a jigsaw puzzle together. Pour some wine and work on it over several nights. A great way to step away from planning and screens.', 'Puzzle Night', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'abdf301c-80b4-4ebf-8672-3c4778fedc3c', 'Read a Book Together', 'Pick a book to read at the same time. Discuss it as you go, like your own two-person book club.', 'Read a Book Together', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '7586f03f-4635-4c9f-96fb-d7d18c332845', 'Relationship Check-In', 'Take 15 minutes to check in with each other. What''s been your high and low this week? What do you need from each other?', 'Relationship Check-In', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'a1fa2dd1-a0d8-41e5-b51c-394729f91c8a', 'Review the Daily I Do To-Do', 'Toggle to the To-Do list below and see if there are any tips you want to revisit and check off what you have completed!', 'Review the Daily I Do To-Do', 1,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'f70eb7b8-8b30-4e87-b1cd-117ba69997e0', 'Social Media Detox Day', 'Take a full day off from social media. No scrolling, no comparing, no wedding hashtag research. Just be present.', 'Social Media Detox Day', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '41931f8f-70e7-4009-999c-212b3327dd72', 'Song of the Day!', 'Need a little wedding energy? Let''s Get it Started!', 'Song of the Day!', 1,
    true, 'Wedding Icon 37.png',
    'Listen Now!', 'https://open.spotify.com/track/37LEkmNdegFwoS55DdL6Ov?si=ffc41da6f2184b6f',
    true, NOW()
),
(
    '29bf324e-22cf-4305-95ef-4f19b2d13ed3', 'Song of the Day!', 'Stuck on a first dance song choice? Check out Dan + Shay''s "Speechless", not your typical first dance song! Will get you thinking!', 'Song of the Day!', 1,
    true, 'Wedding Icon 37.png',
    'Listen Now!', 'https://open.spotify.com/track/3GJ4hzg4lrGwU51Y3VARbF?si=391d608254dd4d08',
    true, NOW()
),
(
    '49afbf63-049a-4cbc-b394-e33de5a164a6', 'Song of the Day!', 'How about a fun recessional song? We love a classic "This Will Be (An Everlasting Love)" by Natalie Cole', 'Song of the Day!', 1,
    true, 'Wedding Icon 37.png',
    'Listen Now!', 'https://open.spotify.com/track/0PDCewmZCp0P5s00bptcdd?si=1adb3d78df3e4d50',
    true, NOW()
),
(
    '7f176b43-0816-4a1d-95a2-e8e0fb760cfb', 'Song of the Day!', 'Jamie''s favorite song at a wedding - "Mr Brightside" by The Killers. Overdone, maybe, but it gets the younger crowd going if played towards the end of the night! What song gets you excited to be on the dance floor?', 'Song of the Day!', 1,
    true, 'Wedding Icon 37.png',
    'Listen Now!', 'https://open.spotify.com/track/003vvx7Niy0yvhvHt4a68B?si=bc42037779c642bf',
    true, NOW()
),
(
    'd9dd9b03-726e-45b6-8723-ae2d86ac10f6', 'Song of the Day!', 'Take a listen to the classic "At Last" by Etta James, most consistently called the most popular wedding song overall and great for first dances, ceremonies or a private last dance.', 'Song of the Day!', 1,
    true, 'Wedding Icon 37.png',
    'Listen Now!', 'https://open.spotify.com/track/4Hhv2vrOTy89HFRcjU3QOx?si=8b25d94fe2804a0d',
    true, NOW()
),
(
    'bda0e23e-d569-4cbd-af13-dbf68cbb2543', 'Stretching and Yoga', 'Do a 20-minute couples yoga session together. YouTube has tons of free videos. It''s surprisingly fun!', 'Stretching and Yoga', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'f140f362-ca17-4fa0-8616-e362d52e3264', 'Sunrise Date', 'Set an alarm and watch the sunrise together. Bring coffee, chairs and a cozy blanket. It''s simple but incredibly romantic.', 'Sunrise Date', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '30956c09-81d0-47f3-8fcb-9eda17d15f3a', 'Take a Cooking Class', 'Book a cooking class together. Italian, sushi, Thai - pick something you both want to learn.', 'Take a Cooking Class', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'e3b6237d-a432-433f-b955-8d113cafa11b', 'Take a Dance Lesson', 'Book a casual dance lesson together - not for the wedding, just for fun. Salsa, swing, or ballroom. It''s a great date night!', 'Take a Dance Lesson', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '358af8cc-068a-4cca-a1e9-0cccd2c90763', 'Take a Hike Together', 'Find a local trail and go for a hike. Nature, exercise, and quality time all in one.', 'Take a Hike Together', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '687a0485-6a0c-4966-8557-586fb01586db', 'Take a Mental Health Day', 'Wedding planning is a marathon, not a sprint. Take today completely off from planning and do something that fills your cup.', 'Take a Mental Health Day', 1,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '9c3e0f3f-2035-49c1-a2af-d5992fbb7ef2', 'Time for a Pintervention!', 'Take time with your Pinterest boards. Clean up pins you no longer like, add new pins you love, make sure it emulates your vision.', 'Time for a Pintervention!', 1,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'e99d8f19-fc58-403b-91d7-9e2d3dc686cb', 'Try a New Restaurant', 'Pick a restaurant you''ve both been curious about but never tried. Make it a date.', 'Try a New Restaurant', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '3c19c085-8119-456a-bfc4-3cf78bae8957', 'Unplug Together', 'Spend one evening completely unplugged. No phones, no TV, no tablets. Just the two of you.', 'Unplug Together', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'f348d150-5fa8-4183-b825-0679eb039e5c', 'Volunteer Together', 'Find a local volunteer opportunity and spend a few hours giving back together.', 'Volunteer Together', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    '9b4b6bd4-834a-4bde-9e9e-0f9179224036', 'Write Future Predictions', 'Each of you write predictions for where you''ll be in 5, 10, and 20 years. Seal them and open on anniversaries.', 'Write Future Predictions', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
),
(
    'c2d89629-2f39-4844-9855-62dcdfb495a7', 'Write Your Love Story', 'Write down the story of how you met and fell in love. Include the details - you''ll want to remember them forever.', 'Write Your Love Story', NULL,
    false, NULL,
    NULL, NULL,
    true, NOW()
);