package com.lordofduct.geom
{
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	public interface IGeometricShape
	{
		function get numAxes():int
		
		/**
		 * Computes the bounding rect of the shape.
		 * 
		 * When transforming the shape the matrix may be generalized returning the 
		 * most extreme rectangle bounding the shape. Meaning transformed shapes' 
		 * bounding rects may not be very accurate but speedy to deduce. 
		 * 
		 * Different shapes implementing this method should give a description of 
		 * the accuracy.
		 * 
		 * @param mat: an option matrix to transform the shape by before computing 
		 * the rect.
		 * 
		 * @return: A Rectangle representing the boundaries
		 */
		function getBoundingRect(mat:Matrix=null):Rectangle
		
		/**
		 * computes the simplest center point of the geometric shape.
		 * 
		 * The choice of word 'simple' is intentional. A shape like a Rectangle 
		 * has one calculatable center point, but a Triangle has thousands of 
		 * different points considered the center. This method will return the 
		 * easiest to compute center point that can be used as the center of mass. 
		 * Most of the time this point should lie inside of the shape for regular 
		 * geometric shapes (Triangle -> inCenter, Rectangle -> Center, Circle -> Center ).
		 * 
		 * But irregular geometric shapes may return a 'simpleCenter' not located 
		 * inside the bounds. For instance a TriangleList may compute a point laying 
		 * outside the bounds. But this still could be considered the center of mass if 
		 * all verts were massed 1.
		 * 
		 * Simplexes will always use a Barycentric coord of <1,1,1>
		 * 
		 * 
		 * @param mat: an option matrix to transform the shape by before computing 
		 * the rect.
		 * 
		 * @return: a Vector2 representing the center
		 */
		function getSimpleCenter(mat:Matrix=null):Vector2
		
		/**
		 * get an axis that represents an indexed side of the geometric shape
		 * 
		 * @param mat: an option Matrix to transform the geometric shape with 
		 * before returning all the axes. If left null, no transformations are 
		 * made. Some geometric shapes may generalize the matrix.
		 */
		function getAxis( index:int, mat:Matrix=null ):Vector2
		
		/**
		 * get all the axes that represent the sides of this geometric shape as 
		 * an array of Vector2s
		 * 
		 * @param mat: an option Matrix to transform the geometric shape with 
		 * before returning all the axes. If left null, no transformations are 
		 * made. Some geometric shapes may generalize the matrix.
		 */
		function getAxes( mat:Matrix=null ):Array
		
		/**
		 * get a normal to an indexed side of the geometric shape
		 * 
		 * @param mat: an option Matrix to transform the geometric shape with 
		 * before returning all the axes. If left null, no transformations are 
		 * made. Some geometric shapes may generalize the matrix.
		 */
		function getAxisNorm( index:int, mat:Matrix=null ):Vector2
		
		/**
		 * get all the normals to the sides of this geometric shape as an array 
		 * of Vector2s
		 */
		function getAxesNorms( mat:Matrix=null ):Array
		
		/**
		 * Projects this geometric shape onto some axis.
		 * 
		 * @param axis: the axis onto which this should be projected
		 * 
		 * @param mat: an optional Matrix to transform the geometry by before projecting. 
		 * If left null, no transformations are made. Some geometric shapes may generalize 
		 * the matrix.
		 * 
		 * @return: an Interval representing the projection onto the axis. Represented 
		 * where min and max are the nearest and furthest distances from the origin on 
		 * said axis.
		 */
		function projectOntoAxis( axis:Vector2, mat:Matrix=null ):Interval
		
		function findExtremitiesOver(axis:Vector2, mat:Matrix=null):Array
		
		function drawToGraphics( gr:Graphics, mat:Matrix=null ):void
	}
}