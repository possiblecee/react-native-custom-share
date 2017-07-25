using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Com.Reactlibrary.RNCustomShare
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNCustomShareModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNCustomShareModule"/>.
        /// </summary>
        internal RNCustomShareModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNCustomShare";
            }
        }
    }
}
