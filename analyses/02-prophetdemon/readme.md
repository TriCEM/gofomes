# README



### Installing Tensorflow on Mac M1
After a battle, this [SO](https://stackoverflow.com/questions/72964800/what-is-the-proper-way-to-install-tensorflow-on-apple-m1-in-2022) was helpful. Really straightforward once understand need to have `python3.10` and use `pip install tensorflow-macos` command. However, need specific version of those programs per issues with model fitting which was solved by this [site](https://developer.apple.com/metal/tensorflow-plugin/) and this [forum](https://developer.apple.com/forums/thread/721619). 
  
Using a [virtual environment]() then: 
```
> which python3.10 --> homebrew hopefully
> /opt/homebrew/bin/python3.10 -m venv venv
> source venv/bin/activate
> pip install tensorflow-macos==2.9
> pip install tensorflow-metal==0.5.0
```
