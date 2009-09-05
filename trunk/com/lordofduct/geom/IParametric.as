/**
 * IParametric - written by Dylan Engelman a.k.a LordOfDuct
 * 
 * Interface written and devised for the LoDGameLibrary. The use of this code 
 * is hereby granted to any user at their own risk. No promises or guarantees 
 * are made by the author. Use at your own risk.
 * 
 * Parametric Curve Package
 * 
 * This group of classes and interfaces defined in the geom package of the LoDGameLibrary 
 * are licensed as non-free open-source code. Use is granted under the permission of the 
 * author Jim Armstrong (http://www.algorithmist.net/) who wrote the original algorithms 
 * used for solving the parametric curves. Reuse of this package of classes is determined 
 * by the original copyright agreement as follows:
 * 
// copyright (c) 2006-2007, Jim Armstrong.  All Rights Reserved. 
//
// This software program is supplied 'as is' without any warranty, express, implied, 
// or otherwise, including without limitation all warranties of merchantability or fitness
// for a particular purpose.  Jim Armstrong shall not be liable for any special incidental, or 
// consequential damages, including, without limitation, lost revenues, lost profits, or 
// loss of prospective economic advantage, resulting from the use or misuse of this software 
// program.
//
// programmed by Jim Armstrong, Singularity (www.algorithmist.net)
 */
package com.lordofduct.geom
{
	import flash.geom.Point;
	
	public interface IParametric
	{
		/**
		 * Add a control point to the Parametric curve
		 * 
		 * ...args set up
		 * for coords - ..., xCoord:Number, yCoord )
		 * for Point, Point2D, or Object - ..., pnt:* )
		 */
		function addControlCoord( ...args ):void
		/**
		 * Move a control point from the Parametric curve
		 * 
		 * ...args set up
		 * for coords - ..., xCoord:Number, yCoord )
		 * for Point, Point2D, or Object - ..., pnt:* )
		 */
		function moveControlCoord( index:uint, ...args ):void
		
		/**
		 * Get a control point
		 */
		function getControlCoord( index:uint ):Point
		
		/**
		 * Remove a control point, all following control points shift 1 space back 
		 * and the index for all subsequent points shifts back 1
		 */
		function removeControlCoord( index:uint ):void
		
		/**
		 * Compute and return the arc length of a curve. This tends to be very heavy work 
		 * so run this method as little as possible. Consider recording this value some where 
		 * and updating it whenever alterations are made to the curve.
		 */
		function arcLength():Number
		
		function reset():void
		
		function getPosition( t:Number ):Point
		
		function getX( t:Number ):Number
		
		function getY( t:Number ):Number
		
		function getPrimePosition( t:Number ):Point
		
		function getPrimeX( t:Number ):Number
		
		function getPrimeY( t:Number ):Number
	}
}